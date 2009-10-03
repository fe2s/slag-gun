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

import com.slaggun.util.Assert;
import com.slaggun.util.ThreadSafe;
import com.slaggun.util.GuardedBy;
import org.apache.log4j.Logger;

import java.util.*;

/**
 * @author Oleksiy Dyagilev (aka.fe2s@gmail.com)
 */

@ThreadSafe
public class OutgoingEventPackets {

    private static Logger log = Logger.getLogger(OutgoingEventPackets.class);

    // outgoing event packets grouped by recipient
    @GuardedBy(value = "this") 
    private Map<Integer, LinkedList<EventPacket>> eventPackets;

    private int queueSizeLimit;

    /**
     * @param queueSizeLimit queue size limit for each recipient
     */
    public OutgoingEventPackets(int queueSizeLimit) {
        this.eventPackets = new HashMap<Integer, LinkedList<EventPacket>>();
        this.queueSizeLimit = queueSizeLimit;
    }

    /**
     * Push the event onto the stack for
     *
     * @param packet     event packet to push
     * @param recipients they are waiting for this packet
     */
    public synchronized void put(EventPacket packet, Set<Integer> recipients) {
        Assert.notNull(packet, "Packet must not be null");
        Assert.notNull(recipients, "Packet must not be null");

        for (Integer recipient : recipients) {
            LinkedList<EventPacket> packetsForRecipient = eventPackets.get(recipient);

            if (packetsForRecipient == null) {
                packetsForRecipient = new LinkedList<EventPacket>();
                eventPackets.put(recipient, packetsForRecipient);
            }

            packetsForRecipient.push(packet);

            int queueSize = packetsForRecipient.size();

            log.debug("Outgoing event packets queue size is " +
                    packetsForRecipient.size() + " for recipient " + recipient);
        }
    }

    /**
     * Has packets for given recipient ?
     *
     * @param recipient recipient
     * @return true if there are some packets
     */
    public synchronized boolean hasPackets(int recipient) {
        LinkedList<EventPacket> packetsForRecipient = eventPackets.get(recipient);
        return packetsForRecipient != null && packetsForRecipient.size() > 0;
    }

    /**
     * Pop all the packets for recipient
     *
     * @param recipient recipient
     * @return queue of the packets
     */
    public synchronized Queue<EventPacket> popAll(int recipient) {
        LinkedList<EventPacket> packets = eventPackets.get(recipient);
        if (packets == null) {
            throw new IllegalArgumentException("Unknown recipient " + recipient + ". " +
                    "Have never had any packets for this recipient");
        }

        // remove all packets
        eventPackets.put(recipient, new LinkedList<EventPacket>());

        return packets;
    }


}
