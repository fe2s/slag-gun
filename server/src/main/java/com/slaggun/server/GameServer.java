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
import com.slaggun.events.OutgoingEventPackets;
import com.slaggun.actor.world.PhysicalWorld;
import org.apache.log4j.Logger;

import java.io.IOException;
import java.net.InetSocketAddress;
import java.nio.ByteBuffer;
import java.nio.channels.SelectionKey;
import java.nio.channels.Selector;
import java.nio.channels.ServerSocketChannel;
import java.nio.channels.SocketChannel;
import java.util.*;
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

    // blocking queue to hold submitted tasks of incoming events packets processing
    private ArrayBlockingQueue<Runnable> packetHandlers;

    // executes submitted tasks of incoming events packets processing
    private ThreadPoolExecutor workersPool;

    // ids of sessions which are currently connected to this server
    private Set<Integer> liveSessionIds;

    // used to generate session id for newcomer connection
    private int sessionIdGenerator = 1;

    // holds outgoing binary packets that are waiting for being sent
    private OutgoingEventPackets outgoingPackets;

    private PhysicalWorld world;

    public GameServer(ServerProperties serverProperties) {
        notNull(serverProperties, "serverProperties must not be null");
        this.serverProperties = serverProperties;
    }

    /**
     * Start game server, so it will be ready to accept connections
     *
     * @throws IOException problems with server initializtion
     */
    public void start() throws IOException {
        initialize();
        acceptConnections();
    }

    /**
     * Prepare game server:
     * - listen socket
     * - prepare workers thread pool
     * - create game world from scratch
     *
     * @return game server
     * @throws IOException error during attempt to listen socket
     */
    public GameServer initialize() throws IOException {
        log.info("Initializing game server");
        ServerSocketChannel serverSocketChannel = ServerSocketChannel.open();
        selector = Selector.open();
        serverSocketChannel.configureBlocking(false);

        // bind to localhost:port
        int port = serverProperties.getGameServerPort();
        log.info("Listening port: " + port);
        serverSocketChannel.socket().bind(new InetSocketAddress(port));

        // register the channel with the selector to handle new socket connections
        serverSocketChannel.register(selector, SelectionKey.OP_ACCEPT);

        // blocking bounded queue to hold submitted tasks setOf incoming events packets processing
        int packetHandlersQueueSize = serverProperties.getPacketHandlersQueueSize();
        packetHandlers = new ArrayBlockingQueue<Runnable>(packetHandlersQueueSize);

        // blocking bounded queue to hold outgoing events packets
        int outgoingPacketsQueueSize = serverProperties.getOutgoingPacketsQueueSize();
        outgoingPackets = new OutgoingEventPackets(outgoingPacketsQueueSize);

        // thread pool for events packets processing
        initializeWorkersPool();

        // create world
        world = new PhysicalWorld();

        // no live sessions yet
        liveSessionIds = new HashSet<Integer>();

        return this;
    }

    /**
     * Accept connections. Main loop of the server.
     */
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

                // set OP_WRITE for those keys which we have waiting events for
                Set<SelectionKey> allKeys = selector.keys();
                for (SelectionKey key : allKeys) {
                    Object attachment = key.attachment();
                    if (attachment == null){
                        continue;
                    }

                    int sessionId = ((Attachment) attachment).getSessionId();
                    if (outgoingPackets.hasPackets(sessionId)) {
                        key.interestOps(SelectionKey.OP_WRITE);
                    }
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
                    }
                    if (key.isReadable()) {
                        read(key);
                    }
                    if (key.isWritable()) {
                        write(key);
                    }
                }
                // don't bother with exceptions in the loop
            } catch (Exception e) {
                log.debug("Error in the loop", e);
            }
        }

    }

    /**
     * Initialize workers thread pool with server properties
     */
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

    /**
     * Accept new connection
     *
     * @param key represents channel of new connection
     * @throws IOException -
     */
    private void accept(SelectionKey key) throws IOException {
        log.debug("Accepting new connection ...");
        ServerSocketChannel serverSocketChannel = (ServerSocketChannel) key.channel();

        // accept new connection
        SocketChannel socketChannel = serverSocketChannel.accept();
        // turn Nagle's algorithm off, use non blocking socket
        socketChannel.socket().setTcpNoDelay(true);
        socketChannel.configureBlocking(false);

        // issue a session id
        int sessionId = nextSessionId();
        liveSessionIds.add(sessionId);
        Attachment attachement = new Attachment(serverProperties.getReadBufferSize(), sessionId);

        // we'd like to be notified when there's data waiting to be read
        socketChannel.register(this.selector, SelectionKey.OP_READ | SelectionKey.OP_WRITE, attachement);
    }

    /**
     * Reads from channel, hands the data off to the worker threads
     * If we've managed to read at least one complete event, set interest in OP_WRITE
     *
     * @param key represents channel of the connection
     * @throws IOException -
     */
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
            log.debug("read " + eventPackets.size() + " event packets");
            log.debug("Enqueue new incoming event packets");

            // protect from modifying
            HashSet<Integer> liveSessionIds = new HashSet<Integer>(this.liveSessionIds);

            EventPacketsHandler handler = new EventPacketsHandler(world, eventPackets, sessionId, liveSessionIds, 
                    outgoingPackets, selector);

            // Hands the data off to our worker threads
            packetHandlers.add(handler);
            log.debug("Packet handlers queue size: " + packetHandlers.size());

        }
        log.debug("reading done");
    }

    /**
     * Writes to channel.
     * Look at the head packet of outgoing queue.
     * If we intersted in it, send to client.
     * <p/>
     *
     * @param key represents channel of the connection
     * @throws IOException -
     */
    private void write(SelectionKey key) throws IOException {
        log.debug("writing to channel...");
        SocketChannel socketChannel = (SocketChannel) key.channel();
        Attachment attachment = (Attachment) key.attachment();

        int sessionId = attachment.getSessionId();

        if (outgoingPackets.hasPackets(sessionId)) {
            // let's send all packets we have for this recipient
            // need to be tested under the load, probably we should split it into the portions

            log.debug("recepient: " + sessionId);

            Queue<EventPacket> packets = outgoingPackets.popAll(sessionId);

            for (EventPacket packet : packets) {
                ByteBuffer packetBuffer = packet.getContentAsBuffer();
                packetBuffer.flip();
                socketChannel.write(packetBuffer);
            }

            log.debug("writing done");

        } else {
            log.debug("Outgoing packets queue for recipient " + sessionId + " is empty. " +
                    "Nothing to write.");
        }

        // resume interest in OP_READ (interest in OP_WRITE is removed)
        key.interestOps(SelectionKey.OP_READ);
    }

    /**
     * Genereates session id for new connection
     *
     * @return session id
     */
    private int nextSessionId() {
        return sessionIdGenerator++;
    }

    /**
     * Notify game server about session disconnect
     *
     * @param sessionId id of the session that was disconnected
     */
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
