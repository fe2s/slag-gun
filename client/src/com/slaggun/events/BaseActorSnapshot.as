/*
 * Copyright 2011 SlagGunTeam
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
 * Unless required by applicable law or agreed to in writing, software distributed under the
 * License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND,
 * either express or implied. See the License for the specific language governing permissions
 * and limitations under the License.
 */

package com.slaggun.events {
import com.slaggun.Game;
import com.slaggun.actor.base.*;
import com.slaggun.util.NotImplementedException;

import flash.utils.getQualifiedClassName;

/**
 * @author: Dmitry Brazhnik (amid.ukr@gmail.com)
 */
public class BaseActorSnapshot implements NewActorSnapshot, UpdateActorSnapshot{
    public var _id:int;

    protected function createActor(game:Game):Actor{
        throw new NotImplementedException(getQualifiedClassName(this) + "::createActor");
    }

    public function newActor(game:Game):Actor {
        var actor:Actor = createActor(game);
        actor.retrieveUpdateSnapshot(game, this);
        return actor;
    }

    public function get id():int {
        return _id;
    }

    public function set id(value:int):void {
        this._id = value;
    }
}
}
