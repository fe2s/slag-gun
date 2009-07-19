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

package com.slaggun.events {
import com.slaggun.actor.base.ActorModel;

/**
 * Transportable actor model
 *
 * @author Oleksiy Dyagilev (aka.fe2s@gmail.com)
 */
[RemoteClass(alias="com.slaggun.events.IdentifiedActorModel")]
public class IdentifiedActorModel {

    private var _actorId:int;
    private var _actorOwner:int;

    private var _actorModel:ActorModel;

    public function IdentifiedActorModel() {
    }

    public function get actorId():int {
        return _actorId;
    }

    public function set actorId(value:int):void {
        _actorId = value;
    }

    public function get actorOwner():int {
        return _actorOwner;
    }

    public function set actorOwner(value:int):void {
        _actorOwner = value;
    }

    public function get actorModel():ActorModel {
        return _actorModel;
    }

    public function set actorModel(value:ActorModel):void {
        _actorModel = value;
    }


    public function toString():String {
        return "IdentifiedActorModel{_actorId=" + String(_actorId) +
               ",_actorOwner=" + String(_actorOwner) +
               ",_actorModel=" + String(_actorModel) + "}";
    }
}
}