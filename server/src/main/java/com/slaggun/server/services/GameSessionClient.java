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
public class GameSessionClient extends GameServer.GameClient {
    private GameServer.GameSession session;

    public GameSessionClient(GameServer gameServer) {
        super(gameServer);
    }

    public void requestSnapshot(){
        ByteBuffer requestSnapshotEvent = ByteBuffer.allocate(GameServer.INT_SIZE);
        requestSnapshotEvent.putInt(0);
        requestSnapshotEvent.clear();

        gameServer.sendDate(gameServer.getServerSide(), this, requestSnapshotEvent);

        super.requestSnapshot();
    }

    @Override
    protected void dataReceived(GameServer.GameClient from, ByteBuffer byteBuffer, boolean skipable) {
        getSession().postBuffer(byteBuffer);
    }

    public GameServer.GameSession getSession() {
        return session;
    }

    public void setSession(GameServer.GameSession session) {
        this.session = session;
    }
}
