/*
 * Copyright 2009 SlagGunTeam
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
 * Unless required by applicable law or agreed to in writing, software distributed under the
 * License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND,
 * either express or implied. See the License for the specific language governing permissions
 * and limitations under the License.
 */

package com.slaggun.server;

import static com.slaggun.util.Assert.notNull;
import com.slaggun.events.EventPacket;
import com.slaggun.events.EventPacketsHandler;
import com.slaggun.events.OutgoingEventPacket;
import org.apache.log4j.Logger;

import java.io.IOException;
import java.net.InetAddress;
import java.net.InetSocketAddress;
import java.nio.ByteBuffer;
import java.nio.Buffer;
import java.nio.channels.SelectionKey;
import java.nio.channels.Selector;
import java.nio.channels.ServerSocketChannel;
import java.nio.channels.SocketChannel;
import java.util.*;
import java.util.concurrent.BlockingQueue;
import java.util.concurrent.ThreadPoolExecutor;
import java.util.concurrent.ArrayBlockingQueue;
import java.util.concurrent.TimeUnit;

/**
 * Multiplexed multithreaded non-blocking game server.
 *
 * @author Oleksiy Dyagilev (aka.fe2s@gmail.com)
 */
public class GameServer {

    private static Logger log = Logger.getLogger(GameServer.class);

    private ServerProperties serverProperties;
    private Selector selector;
    private boolean running;

    // blocking queue to hold submitted tasks of incoming event packets processing
    private ArrayBlockingQueue<Runnable> packetHandlers;

    // executes submitted tasks of incoming event packets processing
    private ThreadPoolExecutor workersPool;

    // ids of sessions which are currently connected to this server
    private Set<Integer> liveSessionIds;

    // used to generate session id for newcomer connection
    private int sessionIdGenerator = 1;

    private ArrayBlockingQueue<OutgoingEventPacket> outgoingPackets;

    public GameServer(ServerProperties serverProperties) {
        notNull(serverProperties, "serverProperties must not be null");
        this.serverProperties = serverProperties;
    }

    public void start() throws IOException {
        initialize();
        acceptConnections();
    }

    public GameServer initialize() throws IOException {
        log.info("Initializing game server");
        ServerSocketChannel serverSocketChannel = ServerSocketChannel.open();
        selector = Selector.open();
        serverSocketChannel.configureBlocking(false);

        // bind to localhost:port
        int port = serverProperties.getGameServerPort();
        InetAddress localhost = InetAddress.getLocalHost();
        log.info("Binding game server to localhost: " + localhost.getHostAddress() + ":" + port);
        serverSocketChannel.socket().bind(new InetSocketAddress(localhost, port));

        // register the channel with the selector to handle new socket connections
        serverSocketChannel.register(selector, SelectionKey.OP_ACCEPT);

        // blocking bounded queue to hold submitted tasks of incoming event packets processing
        int packetHandlersQueueSize = serverProperties.getPacketHandlersQueueSize();
        packetHandlers = new ArrayBlockingQueue<Runnable>(packetHandlersQueueSize);

        // blocking bounded queue to hold outgoing event packets
        int outgoingPacketsQueueSize = serverProperties.getOutgoingPacketsQueueSize();
        outgoingPackets = new ArrayBlockingQueue<OutgoingEventPacket>(outgoingPacketsQueueSize);

        // thread pool for event packets processing
        initializeWorkersPool();

        // no live sessions yet
        liveSessionIds = new HashSet<Integer>();

        return this;
    }

    public void acceptConnections() {
        running = true;
        log.debug("Accept connections");

        workersPool.prestartAllCoreThreads();
        log.debug("Workers pool is ready to process event packets");

        while (running) {
            try {
                // blocking select, may wait for connection for a long time
                int interestingKeysNumber = selector.select();
                if (interestingKeysNumber == 0) {
                    // nothing to do if there are no new acceptable channels
                    continue;
                }

                Set<SelectionKey> readyKeys = selector.selectedKeys();
                Iterator<SelectionKey> keysIterator = readyKeys.iterator();
                while (keysIterator.hasNext()) {
                    SelectionKey key = keysIterator.next();
                    keysIterator.remove();

                    if (!key.isValid()) {
                        continue;
                    }

                    if (key.isAcceptable()) {
                        accept(key);
                    } else if (key.isReadable()) {
                        read(key);
                    } else if (key.isWritable()) {
                        write(key);
                    }
                }
                // don't bother with exceptions in the loop
            } catch (Exception e) {
                log.debug("Error in the loop", e);
            }
        }

    }

    private void initializeWorkersPool() {
        int availableProcessors = serverProperties.getAvailableProcessors();
        int ioThreadsNumber = 1;
        // TODO: for testing
        int corePoolSize = 2;
        int maxPoolSize = 2;
//        int maxPoolSize = availableProcessors == 1 ? 1 : availableProcessors - ioThreadsNumber;
        long keepAliveTime = 10;
        TimeUnit unit = TimeUnit.SECONDS;

        workersPool = new ThreadPoolExecutor(corePoolSize, maxPoolSize, keepAliveTime, unit, packetHandlers);

        log.info("Workers thread pool is initialized with the following:");
        log.info("Core pool size: " + corePoolSize);
        log.info("Max pool size: " + maxPoolSize);
        log.info("Keep alive time: " + "10 " + unit);
    }

    private void accept(SelectionKey key) throws IOException {
        log.debug("Accepting new connection ...");
        ServerSocketChannel serverSocketChannel = (ServerSocketChannel) key.channel();

        // accept new connection
        SocketChannel socketChannel = serverSocketChannel.accept();
        socketChannel.configureBlocking(false);

        // issue a session id
        int sessionId = nextSessionId();
        liveSessionIds.add(sessionId);
        Attachment attachement = new Attachment(serverProperties.getReadBufferSize(), sessionId);

        // we'd like to be notified when there's data waiting to be read
        socketChannel.register(this.selector, SelectionKey.OP_READ, attachement);
    }

    private void read(SelectionKey key) throws IOException {
        log.debug("reading from channel ...");
        SocketChannel socketChannel = (SocketChannel) key.channel();
        Attachment attachment = (Attachment) key.attachment();

        int sessionId = attachment.getSessionId();
        log.debug("session id: " + sessionId + "...");

        ByteBuffer readBuffer = attachment.getReadBuff();
        log.debug("readBuffer postion: " + readBuffer.position());

        // attempt to read the channel
        int numRead;
        try {
            numRead = socketChannel.read(readBuffer);
        } catch (IOException e) {
            // client forcibly closed the connection, cancel the selection key and close the channel
            // remove this session from live ones as well
            key.cancel();
            socketChannel.close();
            sessionWasDisconnected(sessionId);
            return;
        }

        if (numRead == -1) {
            // client closed the socket 
            key.cancel();
            socketChannel.close();
            sessionWasDisconnected(sessionId);
            return;
        }

        // check that we have at least one completely read header
        if (attachment.isHeaderReadCompletely()) {

            List<EventPacket> eventPackets = attachment.cutOffEventPackets();
            log.debug("Enqueue new incoming event packets");

            // shouldn't pass liveSessionIds directly, as it will be modified
            Set<Integer> recipiets = new HashSet<Integer>(liveSessionIds);
            // send to everybody except myself
            recipiets.remove(sessionId);
            EventPacketsHandler handler = new EventPacketsHandler(eventPackets, recipiets, outgoingPackets);

            // Hands the data off to our worker threads
            packetHandlers.add(handler);
            log.debug("Packet handlers queue size: " + packetHandlers.size());

            // set interest in OP_WRITE (interest in OP_READ is removed)
            key.interestOps(SelectionKey.OP_WRITE);
        }
        log.debug("reading done");
    }

    private void write(SelectionKey key) throws IOException {
        log.debug("writing to channel...");
        SocketChannel socketChannel = (SocketChannel) key.channel();
        Attachment attachment = (Attachment) key.attachment();

        int sessionId = attachment.getSessionId();

        if (!outgoingPackets.isEmpty()) {
            // retrieve head packet, but don't remove
            OutgoingEventPacket eventPacket = outgoingPackets.peek();
            Set<Integer> recipientSessionIds = eventPacket.getRecipientSessionIds();
            log.debug("recepients: " + recipientSessionIds);

            // are we interested in this packet ?
            if (recipientSessionIds.contains(sessionId)) {
                ByteBuffer packetBuffer = eventPacket.getContentAsBuffer();
                packetBuffer.flip();
                socketChannel.write(packetBuffer);

                recipientSessionIds.remove(sessionId);

                log.debug("writing done");
            }

            // if have sent to all recipients, remove from the queue
            if (recipientSessionIds.isEmpty()) {
                // TODO: this is actually rather expensive action
                log.debug("removing packet from outgoint queue");
                outgoingPackets.remove(eventPacket);
            }
        } else {
            log.debug("Outgoing packets queue is empty. Nothing to wtite.");
        }

        // resume interest in OP_READ (interest in OP_WRITE is removed)
        key.interestOps(SelectionKey.OP_READ);
    }

    private int nextSessionId() {
        return sessionIdGenerator++;
    }


    private void sessionWasDisconnected(int sessionId) {
        boolean wasRemoved = liveSessionIds.remove(sessionId);
        if (!wasRemoved) {
            throw new IllegalStateException("Client closed the connection, tried to remove his session id " +
                    sessionId + " from live sessions, but didn't find it there. Live session ids:" + liveSessionIds);
        }
    }

    public boolean isRunning() {
        return running;
    }

    public void setRunning(boolean running) {
        this.running = running;
    }
}
