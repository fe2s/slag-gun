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

package com.slaggun.actor.base {
import com.slaggun.Game;
import com.slaggun.Game;
import com.slaggun.Game;
import com.slaggun.Game;
import com.slaggun.Game;
import com.slaggun.Game;
import com.slaggun.actor.base.Actor;
import com.slaggun.actor.base.Actor;
import com.slaggun.actor.base.Actor;
import com.slaggun.actor.base.Actor;
import com.slaggun.actor.base.Actor;
import com.slaggun.actor.base.Actor;
import com.slaggun.util.NotImplementedException;

/**
 * @author Dmitry Brazhnik (amid.ukr@gmail.com)
 */
public class BaseActorPhysics implements ActorPhysics {

    public function liveServer(deltaTime:Number, actor:Actor, world:Game):void {
        liveClient(deltaTime, actor, world);
    }

    public function liveClient(deltaTime:Number, actor:Actor, world:Game):void {
        throw new NotImplementedException("liveClient must be overrided in subclasses of BaseActorPhysics");
    }

    public function createSnapshot(actor:Actor, world:Game):Object {
        return actor.model;
    }

    public function receiveSnapshot(object:Object, actor:Actor, world:Game):void{
        actor.model = ActorModel(object);
    }
}
}