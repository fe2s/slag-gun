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

package com.slaggun;

import com.slaggun.server.Attachment;
import com.slaggun.events.*;
import com.slaggun.amf.AmfSerializerException;
import com.slaggun.amf.AmfSerializer;
import com.slaggun.amf.Amf3Factory;

import java.io.*;
import java.net.InetAddress;
import java.net.InetSocketAddress;
import java.nio.channels.SocketChannel;
import java.nio.channels.Selector;
import java.nio.channels.SelectionKey;
import java.nio.ByteBuffer;
import java.util.List;
import java.util.Set;
import java.util.Iterator;

/**
 * @author Oleksiy Dyagilev (aka.fe2s@gmail.com)
 */
public class GameClient {

    private static final int port = 4001;

    private SocketChannel channel;
    private Selector selector;

    private int eventIdCounter;

    public static void main(String[] args) throws IOException {
        GameClient client = new GameClient();
        client.connect();
        client.start();
    }

    private void connect() throws IOException {
        InetAddress localhost = InetAddress.getLocalHost();

        selector = Selector.open();
        channel = SocketChannel.open(new InetSocketAddress(localhost, port));
        channel.configureBlocking(false);

        // for now session id is generated on server side
        int sessionId = 0;
        int bufferSize = 512;
        Attachment attachment = new Attachment(bufferSize, sessionId);
        channel.register(selector, SelectionKey.OP_WRITE | SelectionKey.OP_READ, attachment);
    }

    private void start() {

        while (true) {
            try {
                int interestingKeysNumber = selector.select();
                if (interestingKeysNumber == 0) {
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

                    if (key.isReadable()) {
                        read(key);
                    } else if (key.isWritable()) {
                        write(key);
                    }
                }

                Thread.sleep(5000);

                // don't bother with exceptions in the loop
            } catch (Exception e) {
                System.out.println("Error in the loop " + e);
            }
        }

    }

    private void read(SelectionKey key) throws IOException, AmfSerializerException {
        System.out.println("reading from channel ...");
        SocketChannel socketChannel = (SocketChannel) key.channel();
        Attachment attachment = (Attachment) key.attachment();

        ByteBuffer readBuffer = attachment.getReadBuff();
        System.out.println("readBuffer postion: " + readBuffer.position());

        // attempt to read the channel
        int numRead;
        try {
            numRead = socketChannel.read(readBuffer);
        } catch (IOException e) {
            // server forcibly closed the connection, cancel the selection key and close the channel
            key.cancel();
            socketChannel.close();
            return;
        }

        if (numRead == -1) {
            // server closed the socket
            key.cancel();
            socketChannel.close();
            return;
        }

        // check that we have at least one completely read header
        if (attachment.isHeaderReadCompletely()) {

            List<EventPacket> eventPackets = attachment.cutOffEventPackets();
            AmfSerializer serializer = Amf3Factory.instance().getAmfSerializer();

            for (EventPacket eventPacket : eventPackets) {
                GameEvent gameEvent = (GameEvent) serializer.fromAmfBytes(eventPacket.getBody().getContent());
                System.out.println(gameEvent);
            }
        }
    }

    private void write(SelectionKey key) throws IOException, AmfSerializerException {
        System.out.println("writing to channel...");
        SocketChannel socketChannel = (SocketChannel) key.channel();

        HzEvent event = new HzEvent(eventIdCounter, eventIdCounter);
        System.out.println("event id: " + eventIdCounter);
        eventIdCounter++;
        AmfSerializer serializer = Amf3Factory.instance().getAmfSerializer();
        byte[] eventBodyBytes = serializer.toAmfBytes(event);

        EventHeader eventHeader = new EventHeader(eventBodyBytes.length);
        EventBody eventBody = new EventBody(eventBodyBytes);
        EventPacket eventPacket = new EventPacket(eventHeader, eventBody);

        ByteBuffer packetBuffer = eventPacket.getContentAsBuffer();
        packetBuffer.flip();
        socketChannel.write(packetBuffer);

    }


}
