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
import com.slaggun.actor.world.PhysicalWorld;
import com.slaggun.actor.world.EventHandler;
import com.slaggun.server.GameServer;

import java.util.List;
import java.util.Set;
import java.util.HashSet;
import java.nio.channels.Selector;

import org.apache.log4j.Logger;

/**
 * Event packets handler.
 * Processes incoming event packets and hands the result off to the outgoing queue.
 *
 * @author Oleksiy Dyagilev (aka.fe2s@gmail.com)
 */
public class EventPacketsHandler implements Runnable {

    private static Logger log = Logger.getLogger(EventPacketsHandler.class);

    private PhysicalWorld world;
	private GameServer gameServer;
    private List<EventPacket> incomingPackets;
    private OutgoingEventPackets outgoingPackets;

    // session id of the player who sent these packets
    private int packetsOwner;
    private Set<Integer> liveSessionIds;

    private Selector selector;

    public EventPacketsHandler(GameServer gameServer, PhysicalWorld world, List<EventPacket> incomingPackets, int packetsOwner,
                               Set<Integer> liveSessionIds, OutgoingEventPackets outgoingPackets, Selector selector) {
        Assert.notNull(incomingPackets, "incomingPackets must not be null");
        Assert.notNull(outgoingPackets, "outgoingPackets must not be null");
        Assert.notNull(world, "world must not be null");
	    Assert.notNull(gameServer, "gameServer must not be null");
        Assert.notNull(liveSessionIds, "liveSessionIds must not be null");

        this.incomingPackets = incomingPackets;
        this.packetsOwner = packetsOwner;
        this.outgoingPackets = outgoingPackets;
        this.world = world;
	    this.gameServer = gameServer;
        this.liveSessionIds = liveSessionIds;
        this.selector = selector;
    }

    public void run() {
        log.debug("start processing new incoming packets");
        log.debug(incomingPackets);
	    AmfSerializer serializer = Amf3Factory.instance().getAmfSerializer();
        for (EventPacket eventPacket : incomingPackets) {
            try {
                // serialize to binary packet to object
                GameEvent gameEvent = serializer.fromAmfBytes(eventPacket.getBody().getContent());
                log.debug(gameEvent);

                // determine recipients
                // protect session ids, deep copy
                Set<Integer> liveSessionIdsCopy =  new HashSet<Integer>(liveSessionIds);
                RecipientsVisitor recipientsVisitor = new RecipientsVisitor(packetsOwner, liveSessionIdsCopy);
                gameEvent.accept(recipientsVisitor);
                Set<Integer> allPossibleRecipients = recipientsVisitor.getRecipients();
	            Set<Integer> recipients = new HashSet<Integer>();
	            for (Integer recipient : allPossibleRecipients) {
		            if(gameServer.checkWaiting(recipient, packetsOwner)){
			            recipients.add(recipient);
		            }
	            }

                // setup owner
                OwnerVisitor ownerVisitor = new OwnerVisitor(packetsOwner);
                gameEvent.accept(ownerVisitor);

                // update world
                EventHandler eventHandler = new EventHandler(world, packetsOwner);
                gameEvent.accept(eventHandler);

                // don't communicate with world, just broadcast event for now
                EventPacket packetToSend = EventPacket.of(gameEvent);
                log.debug("Packet to send:" + packetToSend);

                if (!recipients.isEmpty()){
                    log.debug("Enqueue new outgoing event packets for recipients " + recipients);
                    outgoingPackets.put(packetToSend, recipients);

                    // wake up selector
                    selector.wakeup();
                }

            } catch (AmfSerializerException e) {
                log.error("Can't deserialize byte to object");
            } 
        }
	    gameServer.requestSnapshot(packetsOwner);
        log.debug("event packets handler ... done");
    }

}
