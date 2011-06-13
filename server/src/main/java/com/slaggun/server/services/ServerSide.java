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

package com.slaggun.server.services;

import com.slaggun.server.GameServer;

import java.nio.ByteBuffer;

/**
* @author: Dmitry Brazhnik (amid.ukr@gmail.com)
*/
public class ServerSide extends GameServer.GameClient {

    public ServerSide(GameServer gameServer, int id) {
        super(gameServer, id);
    }

    @Override
    protected void dataReceived(GameServer.GameClient from, ByteBuffer byteBuffer, boolean skipable) {
        for (GameServer.GameClient receiver : gameServer.getClients().values()) {
            // otherSession can be null if it deatached due to concurrecny
            if(receiver != null
            && receiver != from
            && receiver instanceof GameSessionClient){
                receiver.postData(from, byteBuffer.slice(), skipable);
            }
        }
    }

    @Override
    public void postData(GameServer.GameClient from, ByteBuffer byteBuffer, boolean skip) {
        dataReceived(from, byteBuffer, skip);
    }
}
