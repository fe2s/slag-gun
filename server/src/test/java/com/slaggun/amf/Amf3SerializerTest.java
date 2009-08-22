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

package com.slaggun.amf;

import com.slaggun.actor.base.TransportableActor;
import com.slaggun.actor.player.simple.SimplePlayerModel;
import com.slaggun.actor.player.simple.TransportableSimplePlayer;
import com.slaggun.events.SnapshotEvent;
import junit.framework.TestCase;
import org.junit.Test;

import java.util.ArrayList;
import java.util.List;

/**
 * @author Oleksiy Dyagilev (aka.fe2s@gmail.com)
 */

public class Amf3SerializerTest extends TestCase {

    private SerializeTestBean testBean;

    @Override
    protected void setUp() throws Exception {
        testBean = new SerializeTestBean("vasiliy", 25);
    }

    @Test
    public void testAmfBytesRoundTrip() throws AmfSerializerException {
        AmfSerializer serializer = Amf3Factory.instance().getAmfSerializer();
        byte[] amf = serializer.toAmfBytes(testBean);
        assertEquals(testBean, serializer.fromAmfBytes(amf));
    }

    @Test
    public void testAmfStringRoundTrip() throws AmfSerializerException {
        AmfSerializer serializer = Amf3Factory.instance().getAmfSerializer();
        String amf = serializer.toAmfString(testBean);
        System.out.println(amf);
        assertEquals(testBean, serializer.fromAmfString(amf));
    }

    public void testEventRoundTrip() throws AmfSerializerException {
        SimplePlayerModel playerModel = new SimplePlayerModel();

        TransportableActor transActor = new TransportableSimplePlayer();
        transActor.setOwner(2);
        transActor.setId(1);
        transActor.setModel(playerModel);

        List<TransportableActor> transportableActors = new ArrayList<TransportableActor>();
        transportableActors.add(transActor);

        SnapshotEvent snapshot = new SnapshotEvent();
        snapshot.setTransportableActors(transportableActors);

        AmfSerializer serializer = Amf3Factory.instance().getAmfSerializer();
        byte[] snapShotBytes = serializer.toAmfBytes(snapshot);
        SnapshotEvent snapshotAfterTrip = (SnapshotEvent) serializer.fromAmfBytes(snapShotBytes);

        assertEquals(snapshotAfterTrip.getTransportableActors().size(),
                snapshot.getTransportableActors().size());

        assertEquals(snapshotAfterTrip.getTransportableActors().get(0).getId(),
                snapshot.getTransportableActors().get(0).getId());

        assertEquals(snapshotAfterTrip.getTransportableActors().get(0).getOwner(),
                snapshot.getTransportableActors().get(0).getOwner());


    }

}
