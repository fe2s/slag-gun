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

import com.slaggun.events.EventHeader;
import com.slaggun.events.EventPacket;
import com.slaggun.events.EventBody;

import java.nio.ByteBuffer;
import java.util.List;
import java.util.LinkedList;

/**
 * Convention to use read buffer: zero position should
 * always point to the beginning of the header
 *
 * @author Oleksiy Dyagilev (aka.fe2s@gmail.com)
 */
public class Attachment {

    // holds data read from the channel
    // zero position should always point to the beginning of the header
    private ByteBuffer readBuff;
    private int readBufferSize;

    // associated session
    private int sessionId;

    public Attachment(int readBufferSize, int sessionId) {
        this.readBufferSize = readBufferSize;
        // TODO : allocate direct buffer in production
        // TODO : heap buffer is used now for debug purpose
        this.readBuff = ByteBuffer.allocate(readBufferSize);
        this.sessionId = sessionId;
    }

    public boolean isHeaderReadCompletely() {
        return readBuff.position() >= EventHeader.BINARY_SIZE;
    }

    public List<EventPacket> cutOffEventPackets() {
        if (!isHeaderReadCompletely()) {
            throw new IllegalStateException("The header has not been read completely.");
        }

        List<EventPacket> eventPackets = new LinkedList<EventPacket>();
                
        final int headerSize = EventHeader.BINARY_SIZE;

        readBuff.flip();
        int bodySize = 0;

        // read as many complete packets as we have
        while (readBuff.remaining() > headerSize ) {
            // read header
            byte[] headerContent = new byte[headerSize];
            readBuff.get(headerContent, 0, headerSize);
            EventHeader header = new EventHeader(headerContent);

            // read body
            bodySize = header.getBodySize();
            if (readBuff.remaining() >= bodySize){
                byte [] body = new byte[bodySize];
                readBuff.get(body, 0, bodySize);

                // pack header and body together
                EventPacket eventPacket = new EventPacket(header, new EventBody(body));
                eventPackets.add(eventPacket);
            } else {
                // we have only part of the body,
                // stop reading, shift back to the beginning of the header
                readBuff.position(readBuff.position() - headerSize);
                break;
            }
        }

        // prepare buffer for more channel reading
        readBuff.compact();

        return eventPackets;
    }

    public ByteBuffer getReadBuff() {
        return readBuff;
    }

    public void setReadBuff(ByteBuffer readBuff) {
        this.readBuff = readBuff;
    }

    public int getReadBufferSize() {
        return readBufferSize;
    }

    public void setReadBufferSize(int readBufferSize) {
        this.readBufferSize = readBufferSize;
    }

    public int getSessionId() {
        return sessionId;
    }

    public void setSessionId(int sessionId) {
        this.sessionId = sessionId;
    }
}
