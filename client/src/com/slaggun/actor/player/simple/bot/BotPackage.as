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

package com.slaggun.actor.player.simple.bot {
import com.slaggun.actor.base.Actor;
import com.slaggun.actor.base.ActorPackage;
import com.slaggun.actor.player.ActorIdGenerator;
import com.slaggun.actor.player.simple.SimplePlayer;
import com.slaggun.actor.player.simple.SimplePlayerPackage;

public class BotPackage implements ActorPackage{

    public function createPlayer(mine:Boolean = false):Actor {
        var actor:SimplePlayer = SimplePlayer(new SimplePlayerPackage().createPlayer());
        actor.physics = new BotPhysics();

        if (mine) {
            actor.id = ActorIdGenerator.nextId();
        }

        return actor;
    }
}
}