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
import com.slaggun.GameEnvironment;
import com.slaggun.actor.base.AbstractActorSnapshot;
import com.slaggun.actor.base.Actor;
import com.slaggun.actor.base.ActorSnapshot;

/**
 * @author Oleksiy Dyagilev (aka.fe2s@gmail.com)
 */
[RemoteClass(alias="com.slaggun.actor.player.simple.SimplePlayerSnapshot")]
public class SimplePlayerSnapshot extends AbstractActorSnapshot implements ActorSnapshot{

    override public function resurrect(game:GameEnvironment, owner:int):Actor {
        var actor:Actor = new SimplePlayerFactory().create(false);
        actor.id = _id;
        actor.owner = owner;
        actor.physics.receiveSnapshot(_model, actor, game);
        return actor;
    }

}
}