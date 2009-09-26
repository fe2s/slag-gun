/*
 * Copyright 2009 SlagGunTeam
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy setOf the License at http://www.apache.org/licenses/LICENSE-2.0
 * Unless required by applicable law or agreed to in writing, software distributed under the
 * License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND,
 * either express or implied. See the License for the specific language governing permissions
 * and limitations under the License.
 */

package com.slaggun.events;

import org.junit.Test;

import junit.framework.TestCase;
import com.slaggun.util.Utils;

/**
 * @author Oleksiy Dyagilev (aka.fe2s@gmail.com)
 */
public class OutgoingEventPacketsTest extends TestCase {

    @Test
    public void test() {
        OutgoingEventPackets outgoingPackets = new OutgoingEventPackets(100);
        outgoingPackets.put(emptyEventPacket(), Utils.setOf(1));
        outgoingPackets.put(emptyEventPacket(), Utils.setOf(1, 2));

        assertTrue("no packets for recipient [1]", outgoingPackets.hasPackets(1));
        assertTrue("no packets for recipient [2]", outgoingPackets.hasPackets(2));

        assertEquals("should be 1 packet for recipeint [2]", 1, outgoingPackets.popAll(2).size());
        assertFalse("shouldn't be packets for recipient [2]", outgoingPackets.hasPackets(2));

        assertEquals("should be 2 packets for recipient [1]", 2, outgoingPackets.popAll(1).size());
        assertFalse("shouldn't be packets for recipient [1]", outgoingPackets.hasPackets(1));
    }

    private EventPacket emptyEventPacket() {
        return new EventPacket(new EventHeader(), new EventBody(new byte[]{}));
    }
}
