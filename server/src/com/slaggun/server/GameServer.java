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
import com.slaggun.amf.Amf3Factory;
import com.slaggun.amf.AmfSerializer;
import com.slaggun.amf.AmfSerializerException;
import org.apache.log4j.Logger;

import java.io.IOException;
import java.net.InetAddress;
import java.net.InetSocketAddress;
import java.nio.ByteBuffer;
import java.nio.channels.SelectionKey;
import java.nio.channels.Selector;
import java.nio.channels.ServerSocketChannel;
import java.nio.channels.SocketChannel;
import java.util.Iterator;
import java.util.Set;
import java.util.List;

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

//    private ByteBuffer readBuffer = ByteBuffer.allocate(8192);


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
        return this;
    }

    public void acceptConnections() {
        running = true;
        log.debug("Accept connections");

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

                    }
                }
                // don't bother with exceptions in the loop
            } catch (Exception e) {
                log.debug("Error in the loop", e);
            }
        }


    }

    private void accept(SelectionKey key) throws IOException {
        log.debug("Accepting new connection ...");
        ServerSocketChannel serverSocketChannel = (ServerSocketChannel) key.channel();

        // accept new connection
        SocketChannel socketChannel = serverSocketChannel.accept();
        socketChannel.configureBlocking(false);

        // we'd like to be notified when there's data waiting to be read
        Attachment attachement = new Attachment(serverProperties.getReadBufferSize());
        socketChannel.register(this.selector, SelectionKey.OP_READ, attachement);
    }

    private void read(SelectionKey key) throws IOException {
        log.debug("reading ...");
        SocketChannel socketChannel = (SocketChannel) key.channel();
        Attachment attachment = (Attachment) key.attachment();
        ByteBuffer readBuffer = attachment.getReadBuff();

        // attempt to read the channel
        int numRead;
        try {
            numRead = socketChannel.read(readBuffer);
        } catch (IOException e) {
            // client forcibly closed the connection,
            // cancel the selection key and close the channel.
            key.cancel();
            socketChannel.close();
            return;
        }

        if (numRead == -1) {
            // client closed the socket 
            key.cancel();
            socketChannel.close();
            return;
        }

        // check that we have at least one completely read header
        if (attachment.isHeaderReadCompletely()){

            // Hands the data off to our worker threads
            List<EventPacket> eventPackets = attachment.cutOffEventPackets();

            // TODO: just for debug
            log.debug(eventPackets);
            AmfSerializer serializer = Amf3Factory.instance().getAmfSerializer();
            for (EventPacket eventPacket : eventPackets) {
                try {
                    log.debug(serializer.fromAmfBytes(eventPacket.getBody().getContent()));
                } catch (AmfSerializerException e) {
                    log.error("Can't deserialize byte to object");
                }
            }
        }
    }


    public boolean isRunning() {
        return running;
    }

    public void setRunning(boolean running) {
        this.running = running;
    }
}
