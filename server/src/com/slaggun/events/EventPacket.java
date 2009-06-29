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

package com.slaggun.events;

import java.util.Arrays;

/**
 * Binary representation of the event.
 *
 * Structure:
 * [header]
 * [body]
 *
 * @author Oleksiy Dyagilev (aka.fe2s@gmail.com)
 */
public class EventPacket {

    private EventHeader header;
    private EventBody body;

    public EventPacket(EventHeader header, EventBody body) {
        this.header = header;
        this.body = body;
    }

    /**
     * @return size of the packet in bytes
     */
    public int getSize(){
        return EventHeader.BINARY_SIZE + body.getSize();
    }

    public byte[] getContent(){
        byte[] content = new byte[getSize()];
        System.arraycopy(header.getContent(), 0, content, 0, EventHeader.BINARY_SIZE);
        System.arraycopy(body.getContent(), 0, content, EventHeader.BINARY_SIZE, body.getSize());
        return content;
    }

    public EventHeader getHeader() {
        return header;
    }

    public void setHeader(EventHeader header) {
        this.header = header;
    }

    public EventBody getBody() {
        return body;
    }

    public void setBody(EventBody body) {
        this.body = body;
    }

    @Override
    public String toString() {
        return "EventPacket{" +
                "header=" + header +
                ", body=" + body +
                '}';
    }
}
