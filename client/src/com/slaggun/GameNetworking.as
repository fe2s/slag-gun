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

import mx.logging.Log;
import mx.utils.object_proxy;

public class GameNetworking extends EventDispatcher {

    public static const MESSAGE_TYPE_ECHO_SERVICE:int        = 0x0;
    public static const MESSAGE_TYPE_ECHO_ANSWER:int         = 0x1;
    public static const MESSAGE_TYPE_REQUEST_SNAPSHOT:int    = 0x2;
    public static const MESSAGE_TYPE_AMF_MESSAGE:int         = 0x3;
    public static const MESSAGE_TYPE_CLIENT_DISCONNECTED:int = 0x4;
    public static const MESSAGE_TYPE_GET_TIME:int            = 0x5;
    public static const MESSAGE_TYPE_GET_TIME_ANSWER:int     = 0x5;

    public static const SKIP_BIT:int = 0x1;

    public static const BROADCAST_ADDRESS:int = 0;
    public static const SERVER_ADDRESS:int = 1;

    private var log:Logger = Logger.getLogger(GameNetworking);

    private static const gameServerPort:int = 4001;

    private static const policyFilePort:int = 843;


    private var socket:Socket;
    private var bodySize:int = -1;
    private const BODY_SIZE_WARN_LIMIT:int = 1024*1024;

    private var _gameID:int = Math.random() * 0xFFFF;

    private var _serverTimeDifference:Number = 0;
    private var _pingTime:Number             = -1;


    /**
     * Connect to the game server
     */
    public function connect(host:String, policyServer:String):void {
        trace("Connecting to game server");

        var oldSocket:Socket = socket;
        socket = null;
        if(oldSocket != null){
            oldSocket.close();
        }

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

    public function ping(recipient:int, message:String):void {
        sendEvent(MESSAGE_TYPE_ECHO_SERVICE, message, recipient)
    }

    public function broadcastAMF(event:NetworkEvent, important:Boolean = true):void {
        broadcast(MESSAGE_TYPE_AMF_MESSAGE , event, important);
    }

    public function broadcast(messageType:int, event:NetworkEvent, important:Boolean = true):void {
        sendEvent(messageType, event, BROADCAST_ADDRESS, important);
    }

    public function sendEventAMF(event:Object, recipient:int, important:Boolean = true):void {
        sendEvent(MESSAGE_TYPE_AMF_MESSAGE, event, recipient, important);
    }

    private function writeULong(byteArray:ByteArray, number:Number):void{
        byteArray.writeUnsignedInt(((number - uint(number)) / 0x100000000));
        byteArray.writeUnsignedInt(uint(number));
    }

    private function readULong(byteArray:ByteArray):Number{
        var result:Number = byteArray.readUnsignedInt();
        result = 0x100000000 * result + byteArray.readUnsignedInt();
        return result;
    }

    private function requestServerTime():void{
        var byteArray:ByteArray = new ByteArray();
        var time:Number = new Date().time;
        writeULong(byteArray, time);
        sendEvent(MESSAGE_TYPE_GET_TIME, byteArray, SERVER_ADDRESS)
    }

    /**
     * Sends givent event to the server
     * @param event game event
     */
    public function sendEvent(messageType:int, event:Object, recipient:int, important:Boolean = true):void {
        trace("send = " + event);
        if (socket != null && socket.connected) {
            var bytes:ByteArray = new ByteArray();
            bytes.writeInt(recipient);
            bytes.writeInt(important ? 0 : SKIP_BIT);
            bytes.writeInt(messageType);

            if(event is ByteArray){
                bytes.writeBytes(ByteArray(event));
            }else if(event is String){
                bytes.writeUTFBytes(String(event));
            }else{
                if(!event is NetworkEvent){
                    log.warn('Unknow object type  ' + event + ' sent');
                }
                bytes.writeObject(event);
            }

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

            var sender:int      = eventBody.readInt();
            var messageType:int = eventBody.readInt();

            if(sender == SERVER_ADDRESS && messageType == MESSAGE_TYPE_REQUEST_SNAPSHOT){
                event =  DataRecievedEvent.createRequestSnapshot(sender);
            }else if(messageType == MESSAGE_TYPE_ECHO_SERVICE || messageType == MESSAGE_TYPE_ECHO_ANSWER){
                var message:String =  eventBody.readUTFBytes(eventBody.bytesAvailable);
                var status:String  = messageType == MESSAGE_TYPE_ECHO_SERVICE ? 'request':'response'
                log.warn("Client"+sender + ' echo ' + status  + " : '" + message + "'");
                if(messageType == MESSAGE_TYPE_ECHO_SERVICE){
                    sendEvent(MESSAGE_TYPE_ECHO_ANSWER, message, sender, true);
                }
            }else if(sender == SERVER_ADDRESS && messageType == MESSAGE_TYPE_CLIENT_DISCONNECTED){
                event  = DataRecievedEvent.createDisconnected(sender, eventBody.readInt());
            }else if(messageType == MESSAGE_TYPE_AMF_MESSAGE){
                event  = DataRecievedEvent.createIncoming(sender, eventBody.readObject());
            }else if(sender == SERVER_ADDRESS && messageType == MESSAGE_TYPE_GET_TIME_ANSWER){
                var sendTime:Number = readULong(eventBody);
                var serverTime:Number = readULong(eventBody);
                var currentTime:Number = new Date().time;

                _pingTime = currentTime - sendTime;
                _serverTimeDifference = serverTime - sendTime - uint(_pingTime /2);

                log.debug("sendTime: " + sendTime);
                log.debug("serverTime: " + serverTime);

                log.debug("_serverTimeDifference: " + _serverTimeDifference);
                log.debug("_pingTime: " + _pingTime);
                log.debug("Mine time is: " + currentTime);
                log.debug("Assuming server time is: " + (currentTime+ _serverTimeDifference));
            }else{
                log.warn("Skipping event from client" + sender + " with message type " + messageType)
            }

            if(event != null){
                dispatchEvent(event);
            }

            return true;
        }else{
            if(bodySize > BODY_SIZE_WARN_LIMIT){
                log.warn("Network packet is too big,  bodySize: " + bodySize);
            }else{
                log.debug("Waiting for next data, to build packet: " + bodySize);
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
            _pingTime = -1;
            requestServerTime();
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