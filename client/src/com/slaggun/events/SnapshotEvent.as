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
import flash.events.Event;

import mx.collections.ArrayCollection;

/**
 * @author Oleksiy Dyagilev (aka.fe2s@gmail.com)
 */
[RemoteClass(alias="com.slaggun.events.SnapshotEvent")]
public class SnapshotEvent extends Event implements GameEvent {

    public static const INCOMING:String = "Incoming";
    public static const OUTGOING:String = "Outgoing";

    private var _actorModels:ArrayCollection /**<IdentifiedActorModel>*/;

    public function SnapshotEvent(type:String = INCOMING, bubbles:Boolean = false, cancelable:Boolean = false) {
        super(type, bubbles, cancelable);
    }

    public function get actorModels():ArrayCollection {
        return _actorModels;
    }

    public function set actorModels(value:ArrayCollection):void {
        _actorModels = value;
    }

    override public function toString():String {
        return "SnapshotEvent{_actorModels=" + String(_actorModels) + "}";
    }

}
}