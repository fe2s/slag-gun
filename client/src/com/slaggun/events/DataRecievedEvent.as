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

/**
 * @author Dmitry Brazhnik (amid.ukr@gmail.com)
 */
public class DataRecievedEvent extends Event{
    public static const INCOMING:String = "IncomingSnapshot";
    public static const CONNECTED:String = "ConnectedSnapshot";
    public static const REQUEST_SNAPSHOT:String = "RequestSnapshot";
    public static const DISCONNECTED:String = "ClientDisconnected";

    private var _sender:int;

    public function DataRecievedEvent(sender:int, type:String, bubbles:Boolean = false, cancelable:Boolean = false) {
        super(type, bubbles, cancelable);
        this._sender = sender;
    }

    public function get sender():int {
        return _sender;
    }

    public static function createIncoming(sender:int, data:NetworkEvent):AMFRecievedEvent{
        return new AMFRecievedEvent(sender, data, INCOMING);
    }

    public static function createRequestSnapshot(sender:int):DataRecievedEvent{
        return new DataRecievedEvent(sender, REQUEST_SNAPSHOT);
    }

    public static function createConnectedSnapshot():DataRecievedEvent{
        return new DataRecievedEvent(0, CONNECTED);
    }

    public static function createDisconnected(sender:int, disconnectedClientID:int):ClientDisconnectedEvent{
        return new ClientDisconnectedEvent(sender, disconnectedClientID, DISCONNECTED);
    }
}
}