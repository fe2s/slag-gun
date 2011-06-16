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
import flash.events.Event;

/**
 * @author Dmitry Brazhnik (amid.ukr@gmail.com)
 */
public class ClientDisconnectedEvent extends DataRecievedEvent{


    private var _disconnectedClientID:int;

    public function ClientDisconnectedEvent(sender:int, disconnectedClientID:int, type:String, bubbles:Boolean = false, cancelable:Boolean = false) {
        super(sender, type, bubbles, cancelable);
        this._disconnectedClientID = disconnectedClientID;
    }

    public function get disconnectedClientID():int{
        return _disconnectedClientID;
    }
    }
}
