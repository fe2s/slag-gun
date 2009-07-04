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

import com.slaggun.amf.AmfSerializer;
import com.slaggun.amf.Amf3Factory;
import com.slaggun.amf.AmfSerializerException;
import com.slaggun.util.Assert;

import java.util.List;
import java.util.Set;
import java.util.concurrent.BlockingQueue;

import org.apache.log4j.Logger;

/**
 * Event packets handler.
 * Processes incoming event packets and hands the result off to the outgoing queue.
 *
 * @author Oleksiy Dyagilev (aka.fe2s@gmail.com)
 */
public class EventPacketsHandler implements Runnable {

    private static Logger log = Logger.getLogger(EventPacketsHandler.class);

    private List<EventPacket> incomingPackets;
    private Set<Integer> recipientSessionIds;
    private BlockingQueue<OutgoingEventPacket> outgoingPackets;

    public EventPacketsHandler(List<EventPacket> incomingPackets, Set<Integer> recipientSessionIds,
                               BlockingQueue<OutgoingEventPacket> outgoingPackets) {
        Assert.notNull(incomingPackets, "incomingPackets must not be null");
        Assert.notNull(recipientSessionIds, "recipientSessionIds must not be null");
        Assert.notNull(outgoingPackets, "outgoingPackets must not be null");

        this.incomingPackets = incomingPackets;
        this.recipientSessionIds = recipientSessionIds;
        this.outgoingPackets = outgoingPackets;
    }

    public void run() {
        log.debug("start processing new incoming packets");
        log.debug(incomingPackets);

        AmfSerializer serializer = Amf3Factory.instance().getAmfSerializer();
        for (EventPacket eventPacket : incomingPackets) {
            try {
                GameEvent gameEvent = (GameEvent) serializer.fromAmfBytes(eventPacket.getBody().getContent());
                log.debug(gameEvent);

                // back to packet
                byte[] body = serializer.toAmfBytes(gameEvent);
                int bodySize = body.length;
                OutgoingEventPacket outgoingPacket =
                        new OutgoingEventPacket(new EventHeader(bodySize), new EventBody(body), recipientSessionIds);

                log.debug("Enqueue new outgoing event packets");
                outgoingPackets.put(outgoingPacket);
                log.debug("Outgoing packets queue size: " + outgoingPackets.size());


            } catch (AmfSerializerException e) {
                log.error("Can't deserialize byte to object");
            } catch (InterruptedException e) {
                log.error("Error during put to outgoing packets queue", e);
            }
        }


        // TODO: for testing
        try {
            Thread.sleep(1000);
        } catch (InterruptedException e) {
        }
    }
}
