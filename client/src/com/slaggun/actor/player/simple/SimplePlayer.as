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

package com.slaggun.actor.player.simple {
import com.slaggun.actor.base.AbstractActor;
import com.slaggun.actor.base.Actor;
import com.slaggun.actor.base.TransportableActor;
import com.slaggun.actor.player.renderer.StalkerPlayerResource;

/**
 * This is the first implementation of user controlled game character
 *
 * Author Dmitry Brazhnik (amid.ukr@gmail.com)
 *
 * @see Actor
 * @see SimplePlayerPhysics
 */
public class SimplePlayer extends AbstractActor implements Actor {

    public function SimplePlayer() {
        _physics = new SimplePlayerPhysics();
        _renderer = StalkerPlayerResource.createRenderer();
        _model = new SimplePlayerModel();
    }


    override public function compact():TransportableActor {
        var trans:TransportableSimplePlayer = new TransportableSimplePlayer();
        trans.id = _id;
        trans.model = _model;
        trans.owner = _owner;
        return trans;
    }
}
}