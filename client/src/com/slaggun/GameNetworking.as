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
import com.slaggun.events.DataRecievedEvent;
import com.slaggun.events.NetworkEvent;
import com.slaggun.log.Logger;

import flash.events.ErrorEvent;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.IOErrorEvent;
import flash.events.ProgressEvent;
import flash.events.SecurityErrorEvent;
import flash.net.Socket;
import flash.system.Security;
import flash.utils.ByteArray;

public class GameNetworking extends EventDispatcher {

    public static const SKIP_BIT:int = 0x1;

    public static const BROADCAST_ADDRESS:int = 0;

    private var log:Logger = Logger.getLogger(GameNetworking);

    private static const gameServerPort:int = 4001;

    private static const policyFilePort:int = 843;


    private var socket:Socket;
    private var bodySize:int = -1;
    private const BODY_SIZE_WARN_LIMIT:int = 1024*1024;

    private var _gameID:int = Math.random() * 0xFFFF;

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

    public function broadcast(event:NetworkEvent, important:Boolean = true):void {
        sendEvent(event, BROADCAST_ADDRESS, important);
    }

    /**
     * Sends givent event to the server
     * @param event game event
     */
    public function sendEvent(event:NetworkEvent, recipient:int, important:Boolean = true):void {
        trace("send = " + event);
        if (socket != null && socket.connected) {
            var bytes:ByteArray = new ByteArray();
            bytes.writeInt(recipient);
            bytes.writeInt(important ? 0 : SKIP_BIT);
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
        const BINARY_SIZE:int = 4;

        if(socket == null || !socket.connected){
            return false;
        }

        if(bodySize == -1 && socket.bytesAvailable >= BINARY_SIZE){
            bodySize = socket.readInt();
        }

        if (bodySize != -1 && socket.bytesAvailable >= bodySize) {
            var eventBody:ByteArray = new ByteArray();
            socket.readBytes(eventBody, 0, bodySize);
            bodySize = -1;


            var event:DataRecievedEvent;

            var sender:int = eventBody.readInt();
            if(sender == 0){
                event =  DataRecievedEvent.createRequestSnapshot();
            }else{
                event  = DataRecievedEvent.createIncoming(sender, eventBody.readObject());
            }

            dispatchEvent(event);

            return true;
        }else{
            if(bodySize > BODY_SIZE_WARN_LIMIT){
                log.warn("Network packet is too big,  bodySize: " + bodySize);
            }else{
                log.warn("Waiting for next data, to build packet: " + bodySize);
            }
            return false;
        }
    }

    public function get gameID():int {
        return _gameID;
    }

    public function get connected():Boolean{
        return socket != null && socket.connected;
    }

    /**
     * Handles connection events
     */
    private function connectHandler(event:Event):void {
        trace("connectHandler: " + event);
        if (socket.connected) {
            log.info("connected...");
            dispatchEvent(DataRecievedEvent.createConnectedSnapshot());
        } else {
            log.info("unable to connect");
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
        log.info("closeHandler: " + event);
    }

    private function errorHandler(event:IOErrorEvent):void {
        log.info("errorHandler: " + event);
    }

    private function securityErrorHandler(event:SecurityErrorEvent):void {
        log.info("securityErrorHandler: " + event);
    }

    private function progressHandler(event:ProgressEvent):void {
        log.info("progressHandler: " + event);
    }

    private function ioErrorHandler(event:IOErrorEvent):void {
        log.info("ioErrorHandler: " + event);
    }
}
}