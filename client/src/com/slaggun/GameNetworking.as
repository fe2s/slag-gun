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

package com.slaggun {
import com.slaggun.net.*;
import com.slaggun.amf.AmfSerializer;
import com.slaggun.events.BaseGameEvent;
import com.slaggun.events.GameEvent;
import com.slaggun.events.RequestSnapshotEvent;
import com.slaggun.util.log.Logger;

import flash.events.ErrorEvent;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.IOErrorEvent;
import flash.events.ProgressEvent;
import flash.events.SecurityErrorEvent;
import flash.net.Socket;
import flash.system.Security;
import flash.utils.ByteArray;

import mx.controls.Alert;

public class GameNetworking extends EventDispatcher {

    public static const BROADCAST_ADDRESS:int = 0;

    private var log:Logger = Logger.getLogger(GameNetworking);

    private static const gameServerPort:int = 4001;

    private static const policyFilePort:int = 843;


    private var socket:Socket;

    private var serializer:AmfSerializer = AmfSerializer.instance();

    /**
     * Connect to the game server
     */
    public function connect(host:String, policyServer:String):void {
        trace("Connecting to game server");

        if(policyServer == null){
            policyServer = host;
        }

        var policyFileLocation:String = "xmlsocket://" + policyServer + ":" + policyFilePort;

        Security.loadPolicyFile(policyFileLocation);

        try {

            socket = new Socket();

            // network events
            addNetworkEventListeners();

            socket.connect(host, gameServerPort);

        } catch (e:Error) {
            trace(e);
            throw e;
        }
    }

    /**
     * Sends givent event to the server
     * @param event game event
     */
    public function sendEvent(event:GameEvent, recipient:int):void {
        trace("send = " + event);
        if (socket != null && socket.connected) {
            var bytes:ByteArray = new ByteArray();
            bytes.writeInt(recipient);
            bytes.writeObject(event);
            socket.writeInt(bytes.length);
            socket.writeBytes(bytes);
            socket.flush();
        } else {
            trace("Not connected, can't send bytes");
        }
    }

    /**
     * Handles incoming binary data
     */
    public function dataHandler(progressEvent:ProgressEvent):Boolean {
//        trace("dataHandler: " + progressEvent);
        // TODO: need to consider case when header has been read,
        // TODO: but body is not available yet
        if(socket == null){
            return false;
        }
        
        if (socket.bytesAvailable > EventHeader.BINARY_SIZE) {
            // read header

            log.info("Message income, size: " + socket.bytesAvailable);

            var bodySize:int = socket.readInt();

            log.info("Message body size: " + bodySize);
            log.info("Buffer size: " + socket.bytesAvailable);

            if (socket.bytesAvailable >= bodySize) {
                var eventBody:ByteArray = new ByteArray();
                socket.readBytes(eventBody, 0, bodySize);


                var event:BaseGameEvent;

                var sender:int = eventBody.readInt();
                if(sender == 0){
                    event = new RequestSnapshotEvent();
                }else{
                    event = BaseGameEvent(eventBody.readObject());
                }

                event.sender = sender;
                trace("Incoming event:" + event);
                dispatchEvent(event);
            }else{
                Alert.show("Can't successfuly read");
            }

            return true;
        }else{
            return false;
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
        socket.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
        socket.addEventListener(ErrorEvent.ERROR, errorHandler);
    }

    private function closeHandler(event:Event):void {
        socket = null;
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