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

package com.slaggun.net {
import com.slaggun.actor.world.PhysicalWorld;
import com.slaggun.amf.AmfSerializer;

import com.slaggun.net.EventHeader;
import com.slaggun.events.GameEvent;
import com.slaggun.net.EventPacket;

import com.slaggun.events.SnapshotEvent;

import flash.events.DataEvent;
import flash.events.ErrorEvent;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.IOErrorEvent;
import flash.events.ProgressEvent;
import flash.events.SecurityErrorEvent;
import flash.net.Socket;
import flash.system.Security;
import flash.utils.ByteArray;

public class GameClient extends EventDispatcher {

    private static const gameServerPort:int = 4001;
    private static const gameServerIp:String = "127.0.0.1";

    private static const policyFilePort:int = 843;
    private static const policyFileLocation:String = "xmlsocket://" + gameServerIp + ":" + policyFilePort;

    private var socket:Socket;

    private var serializer:AmfSerializer = AmfSerializer.instance();

    private var world:PhysicalWorld;

    public function GameClient(world:PhysicalWorld) {
        this.world = world;
        this.addGameEventListeners();
    }

    /**
     * Connect to the game server
     */
    public function connect():void {
        trace("Connecting to game server");

        Security.loadPolicyFile(policyFileLocation);

        try {

            socket = new Socket();

            // network events
            addNetworkEventListeners();

            socket.connect(gameServerIp, gameServerPort);

        } catch (e:Error) {
            trace(e);
            throw e;
        }
    }

    /**
     * Notifies net game client to fire event
     */
    public function notify():void {
        sendEvent(world.snapshot);
    }

    /**
     * Sends givent event to the server
     * @param event game event
     */
    private function sendEvent(event:GameEvent):void {
        if (socket != null && socket.connected) {
            var eventPacket:EventPacket = EventPacket.of(event);
            send(eventPacket.content);
        } else {
            // not connected yet, waiting for connection
            //            outgointEvents.push(event);
        }
    }

    /**
     * send bytes to socket server
     */
    private function send(bytes:ByteArray):void {
        if (socket.connected) {
            socket.writeBytes(bytes);
            socket.flush();
        } else {
            trace("Not connected, can't send bytes");
        }
    }

    /**
     * Handles incoming binary data
     */
    private function dataHandler(progressEvent:ProgressEvent):void {
//        trace("dataHandler: " + progressEvent);
        // TODO: need to consider case when header has been read,
        // TODO: but body is not available yet
        while (socket.bytesAvailable > EventHeader.BINARY_SIZE) {
            // read header
            var bodySize:int = socket.readInt();
            if (socket.bytesAvailable >= bodySize) {
                var eventBody:ByteArray = new ByteArray();
                socket.readBytes(eventBody, 0, bodySize);

                var event:Event = Event(AmfSerializer.instance().fromAmfBytes(eventBody));
//                trace("Incoming event:" + event);
                dispatchEvent(event);
            }
        }
    }


    /**
     * Handles connection events
     */
    private function connectHandler(event:Event):void {
        trace("connectHandler: " + event);
        if (socket.connected) {
            trace("connected...\n");
        } else {
            trace("unable to connect\n");
        }
    }


    private function addNetworkEventListeners():void {
        socket.addEventListener(Event.CLOSE, closeHandler);
        socket.addEventListener(Event.CONNECT, connectHandler);
        socket.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
        socket.addEventListener(ProgressEvent.SOCKET_DATA, dataHandler);
        socket.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
        socket.addEventListener(ErrorEvent.ERROR, errorHandler);
    }

    private function addGameEventListeners():void {
        addEventListener(SnapshotEvent.INCOMING, world.handleSnapshot);
    }

    private function closeHandler(event:Event):void {
        trace("closeHandler: " + event);
    }

    private function errorHandler(event:IOErrorEvent):void {
        trace("errorHandler: " + event);
    }

    private function securityErrorHandler(event:SecurityErrorEvent):void {
        trace("securityErrorHandler: " + event);
    }

    private function progressHandler(event:ProgressEvent):void {
        trace("progressHandler: " + event);
    }

    private function ioErrorHandler(event:IOErrorEvent):void {
        trace("ioErrorHandler: " + event);
    }
}
}