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
import com.slaggun.actor.base.Actor;
import com.slaggun.actor.base.ActorModel;
import com.slaggun.actor.base.TransportableActor;

/**
 * @author Oleksiy Dyagilev (aka.fe2s@gmail.com)
 */
[RemoteClass(alias="com.slaggun.actor.player.simple.TransportableSimplePlayer")]
public class TransportableSimplePlayer implements TransportableActor{

    private var _id:int;
    private var _owner:int;
    private var _model:ActorModel;

    public function resurrect():Actor {
        var actor:Actor = new SimplePlayerFactory().create(false);
        actor.model = _model;
        actor.id = _id;
        actor.owner = _owner;
        return actor;
    }

    public function get id():int {
        return _id;
    }

    public function set id(value:int):void {
        _id = value;
    }

    public function get owner():int {
        return _owner;
    }

    public function set owner(value:int):void {
        _owner = value;
    }

    public function get model():ActorModel {
        return _model;
    }

    public function set model(value:ActorModel):void {
        _model = value;
    }

}
}