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
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

/**
 *
 * <dl>
 *  <dt>Incomming packet:</dt>
 * <dd>size:int</dd>
 * <dd>to:int</dd>
 * <dd>flag:int</dd>
 * <dd>mt:int</dd>
 * <dd>body:byte[size - 3 * int]</dd>
 * <dd/>
 * <dt>Outcomming packet:</dt>
 * <dd>size:int</dd>
 * <dd>from:int</dd>
 * <dd>mt:int</dd>
 * <dd>body:byte[size - 2 * int]</dd>
 * </dl>
 *
* @author Dmitry Brazhnik (amid.ukr@gmail.com)
*/
public class GameSessionClient extends GameServer.GameClient {
    private GameServer.GameSession session;
		private final Map<GameServer.GameClient, Object> dataRetrieved = new ConcurrentHashMap<GameServer.GameClient, Object>();

    public GameSessionClient(GameServer gameServer) {
        super(gameServer);
    }

    public void requestSnapshot(){
        sendMessage(gameServer.getServerService(), GameServer.MESSAGE_TYPE_REQUEST_SNAPSHOT);
        dataRetrieved.clear();
    }


    /**
     *
     * <dl>
     *  <dt>Argument packedBuffer:</dt>
     * <dd>size:int</dd>
     * <dd>from:int</dd>
     * <dd>mt:int</dd>
     * <dd>body:byte[]</dd>
     * </dl>
     *
     * @param from
     * @param packedBuffer
     * @param skip
     */
    public void postData(GameServer.GameClient from, ByteBuffer packedBuffer, boolean skip){
        if(canSend(from, skip)){
            getSession().postBuffer(packedBuffer);

            if(skip){
                dataRetrieved.put(from, new Object());
            }
        }
    }

    public static ByteBuffer pack(GameServer.GameClient from, ByteBuffer mtByteBuffer){
        ByteBuffer buffer = ByteBuffer.allocate(2*GameServer.INT_SIZE + mtByteBuffer.remaining());
        buffer.putInt(buffer.capacity() - GameServer.INT_SIZE);
        buffer.putInt(from.getSessionId());
        buffer.put(mtByteBuffer);

        buffer.clear();

        return buffer;
    }

    @Override
    public void sendMessage(GameServer.GameClient from, int messageType, ByteBuffer byteBuffer, boolean skip) {
        if(canSend(from, skip)){
            int buffSize = byteBuffer != null ? byteBuffer.remaining() : 0;

            ByteBuffer packedBuffer = ByteBuffer.allocate(3 * GameServer.INT_SIZE + buffSize);

            packedBuffer.putInt(packedBuffer.capacity() - GameServer.INT_SIZE);
            packedBuffer.putInt(from.getSessionId());
            packedBuffer.putInt(messageType);

            if(byteBuffer != null) packedBuffer.put(byteBuffer);

            packedBuffer.clear();

            postData(from, packedBuffer, skip);
        }
    }

    public boolean canSend(GameServer.GameClient from, boolean skip){
        return !skip || !dataRetrieved.containsKey(from);
    }

    @Override
    protected void dataReceived(GameServer.GameClient from, ByteBuffer mtByteBuffer, boolean skipable) {
        if(canSend(from, skipable)){
            postData(from, pack(from, mtByteBuffer), skipable);
        }
    }

    public GameServer.GameSession getSession() {
        return session;
    }

    public void setSession(GameServer.GameSession session) {
        this.session = session;
    }
}
