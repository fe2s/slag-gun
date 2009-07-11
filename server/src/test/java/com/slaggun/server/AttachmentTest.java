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
import junit.framework.TestCase;
import org.junit.Test;

import java.nio.ByteBuffer;
import java.util.Arrays;
import java.util.List;

/**
 * @author Oleksiy Dyagilev (aka.fe2s@gmail.com)
 */
public class AttachmentTest extends TestCase {

    /**
     * Tests cutting off event packets.
     * Three packets has been written and the fourth one partially in the same session.
     */
    @Test
    public void testCutOff_oneSession() {
        Attachment attachment = new Attachment(512, 1);

        int firstEventBodySize = 10;
        int secondEventBodySize = 7;
        int thirdEventBodySize = 12;
        int fourthEventBodySize = 20;

        ByteBuffer readBuffer = attachment.getReadBuff();

        // add event packets
        readBuffer.put(createEventPacket(firstEventBodySize).getContent());
        readBuffer.put(createEventPacket(secondEventBodySize).getContent());
        readBuffer.put(createEventPacket(thirdEventBodySize).getContent());

        // add last non-complete event
        byte[] fourthEvent = createEventPacket(fourthEventBodySize).getContent();
        int fourthEventFirstPartSize = 14;
        readBuffer.put(fourthEvent, 0, fourthEventFirstPartSize);

        // cut off complete event packets
        List<EventPacket> packets = attachment.cutOffEventPackets();

        // test number of packets
        assertEquals(packets.size(), 3);

        // test headers
        assertEquals(firstEventBodySize, packets.get(0).getHeader().getBodySize());
        assertEquals(secondEventBodySize, packets.get(1).getHeader().getBodySize());
        assertEquals(thirdEventBodySize, packets.get(2).getHeader().getBodySize());

        // test bodies
        assertEquals(firstEventBodySize, packets.get(0).getBody().getSize());
        assertEquals(secondEventBodySize, packets.get(1).getBody().getSize());
        assertEquals(thirdEventBodySize, packets.get(2).getBody().getSize());
    }

    /**
     * Write three complete event packets and the fourth one partially.
     * Cutt off complete event packets.
     * Finish writing the second part of the fourth packet in another session.
     * Cutt off complete events.
     */
    public void testCutOff_twoSessions() {
        Attachment attachment = new Attachment(512, 1);

        int firstEventBodySize = 10;
        int secondEventBodySize = 7;
        int thirdEventBodySize = 12;
        int fourthEventBodySize = 20;

        ByteBuffer readBuffer = attachment.getReadBuff();

        // add event packets
        readBuffer.put(createEventPacket(firstEventBodySize).getContent());
        readBuffer.put(createEventPacket(secondEventBodySize).getContent());
        readBuffer.put(createEventPacket(thirdEventBodySize).getContent());

        // add last non-complete
        EventPacket fourthEvent = createEventPacket(fourthEventBodySize);
        byte[] fourthEventContent = fourthEvent.getContent();
        int fourthEventFirstPartSize = 14;
        readBuffer.put(fourthEventContent, 0, fourthEventFirstPartSize);

        // cut off complete event packets
        List<EventPacket> packets = attachment.cutOffEventPackets();

        // test number of packets
        assertEquals(packets.size(), 3);

        // write the second part of the fourth packet in another session
        readBuffer.put(fourthEventContent, fourthEventFirstPartSize, fourthEvent.getSize() - fourthEventFirstPartSize);

        // cut off complete event packets
        packets = attachment.cutOffEventPackets();

        // test number of packets
        assertEquals(packets.size(), 1);

        // test header
        assertEquals(fourthEventBodySize, packets.get(0).getHeader().getBodySize());

        // test body
        assertEquals(fourthEventBodySize, packets.get(0).getBody().getSize());

    }

    private EventPacket createEventPacket(int bodySize) {
        EventHeader header = new EventHeader(bodySize);

        byte[] bodyContent = new byte[bodySize];
        Arrays.fill(bodyContent, (byte) 1);
        EventBody body = new EventBody(bodyContent);

        return new EventPacket(header, body);
    }
}
