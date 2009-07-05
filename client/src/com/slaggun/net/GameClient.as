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
import flash.events.DataEvent;
import flash.events.ErrorEvent;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.ProgressEvent;
import flash.events.SecurityErrorEvent;
import flash.net.Socket;
import flash.system.Security;

public class GameClient {

    private static const gameServerPort:int = 4001;
    private static const gameServerIp:String = "192.168.1.4";

    private static const policyFilePort:int = 843;
    private static const policyFileLocation:String = "xmlsocket://" + gameServerIp + ":" + policyFilePort;

    private var socket:Socket;

    public function GameClient() {
    }

    public function connect():void {
        trace("Connecting to game server");

        Security.loadPolicyFile(policyFileLocation);

        try {

            socket = new Socket();

            socket.addEventListener(Event.CLOSE, closeHandler);
            socket.addEventListener(Event.CONNECT, connectHandler);
            socket.addEventListener(DataEvent.DATA, dataHandler);
            socket.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
            socket.addEventListener(ProgressEvent.PROGRESS, progressHandler);
            socket.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
            socket.addEventListener(ErrorEvent.ERROR, errorHandler);


            socket.connect(gameServerIp, gameServerPort);

        } catch (e:Error) {
            trace(e);
            throw e;
        }

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

    private function dataHandler(event:DataEvent):void {
        trace("dataHandler: " + event);
    }

    private function connectHandler(event:Event):void {
        trace("connectHandler: " + event);
        if (socket.connected) {
            trace("connected...\n");
        } else {
            trace("unable to connect\n");
        }
    }

    private function closeHandler(event:Event):void {
        trace("closeHandler: " + event);
    }


}
}