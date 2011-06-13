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
import com.slaggun.actor.base.Actor;
import com.slaggun.actor.base.ActorModel;
import com.slaggun.actor.player.simple.SimplePlayer;

import flash.utils.getDefinitionByName;

/**
 * @author: Dmitry Brazhnik (amid.ukr@gmail.com)
 */
[RemoteClass(alias="com.slaggun.events.SimpleActorSnapshot")]
public class SimpleActorSnapshot extends BaseActorSnapshot{
    public var _model:ActorModel;
    public var _className:String;

    public function SimpleActorSnapshot(className:String = "", model:ActorModel = null) {
        this._model = model;
        this._className = className;
    }

    public function get model():ActorModel {
        return _model;
    }

    override protected function createActor(game:Game):Actor {
        var clazz:Class = getDefinitionByName(_className)  as Class;
        return new clazz();
    }
}
}
