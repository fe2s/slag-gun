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
import com.slaggun.util.Utils;
import org.apache.log4j.Logger;

import java.nio.ByteBuffer;
import java.util.Date;

/**
 * @author: Dmitry Brazhnik (amid.ukr@gmail.com)
 */
public class ServerService extends GameServer.GameClient{
    private static final Logger LOGGER = Logger.getLogger(ServerService.class);

    public ServerService(GameServer gameServer, int id) {
        super(gameServer, id);
    }

    public void echo(GameServer.GameClient to, String messsage) {
        to.sendMessage(this, GameServer.MESSAGE_TYPE_ECHO_SERVICE, ByteBuffer.wrap(Utils.toUTF8(messsage)));
    }

    @Override
    protected void dataReceived(GameServer.GameClient from, ByteBuffer mtByteBuffer, boolean skipable) {
        int messageType = mtByteBuffer.getInt();


        switch (messageType){
            case GameServer.MESSAGE_TYPE_ECHO_SERVICE:
            case GameServer.MESSAGE_TYPE_ECHO_ANSWER:
                byte buf[] = new byte[mtByteBuffer.remaining()];
                mtByteBuffer.get(buf);
                LOGGER.info("Client" + from.getSessionId() + " echo: '" + Utils.fromUTF8(buf));
                if(messageType == GameServer.MESSAGE_TYPE_ECHO_SERVICE){
                    from.sendMessage(this, GameServer.MESSAGE_TYPE_ECHO_ANSWER, ByteBuffer.wrap(buf));
                }
                break;
            case GameServer.MESSAGE_TYPE_GET_TIME:
                long senderTime = mtByteBuffer.getLong();
                long serverTime = new Date().getTime();

                ByteBuffer buff = ByteBuffer.allocate(2 * Long.SIZE / 8);
                buff.putLong(senderTime);
                buff.putLong(serverTime);
                buff.position(0);

                from.sendMessage(this, GameServer.MESSAGE_TYPE_GET_TIME_ANSWER, buff);

                LOGGER.debug("Java time: " + serverTime + ", Flex time: " + senderTime);
                break;
        }
    }
}
