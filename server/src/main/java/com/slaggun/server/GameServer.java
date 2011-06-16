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

package com.slaggun.server;

import com.slaggun.server.services.BroadcastService;
import com.slaggun.server.services.ServerService;
import com.slaggun.server.services.GameSessionClient;
import com.slaggun.util.Utils;
import org.apache.log4j.Logger;

import java.nio.ByteBuffer;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.atomic.AtomicInteger;

/**
 * @author Dmitry Brazhnik (amid.ukr@gmail.com)
 */
public class GameServer extends BaseUnblockingServer<GameServer.GameSession> {

    public static final int MESSAGE_TYPE_ECHO_SERVICE = 0x0;
    public static final int MESSAGE_TYPE_ECHO_ANSWER = 0x1;
    public static final int MESSAGE_TYPE_REQUEST_SNAPSHOT = 0x2;
    public static final int MESSAGE_TYPE_AMF_MESSAGE = 0x3; // Reserved for client interactions
    public static final int MESSAGE_TYPE_CLIENT_DISCONNECTED = 0x4;


    public static final int SKIP_BIT = 0x1;
	public static final int INT_SIZE = Integer.SIZE/8;

	private final Logger log = Logger.getLogger(GameServer.class);

    public static abstract class GameClient{
        protected final GameServer gameServer;
		private final int sessionId;

		protected GameClient(GameServer gameServer) {
			this(gameServer, gameServer.freeSessionId.getAndIncrement());
		}

		public GameClient(GameServer gameServer, int id) {
            this.gameServer = gameServer;
			sessionId = id;
			gameServer.clients.put(sessionId, this);
		}

		public int getSessionId() {
			return sessionId;
		}

        /**
         * * <dl>
         *  <dt>Argument mtByteBuffer:</dt>
         * <dd>mt:int</dd>
         * <dd>body:byte[]</dd>
         * </dl>
         *
         * @param from
         * @param mtByteBuffer
         * @param skipable
         */
		protected abstract void dataReceived(GameClient from, ByteBuffer mtByteBuffer, boolean skipable);

        public void sendMessage(GameClient from, int messageType, boolean skip){
            sendMessage(from, messageType, null, skip);
        }

        public void sendMessage(GameClient from, int messageType, ByteBuffer byteBuffer){
            sendMessage(from, messageType, byteBuffer, false);
        }

        public void sendMessage(GameClient from, int messageType){
            sendMessage(from, messageType, null, false);
        }

        public void sendMessage(GameClient from, int messageType, ByteBuffer byteBuffer, boolean skip){
            int buffSize = byteBuffer != null ? byteBuffer.remaining() : 0;
            ByteBuffer buffer = ByteBuffer.allocate(buffSize + INT_SIZE);
            buffer.putInt(messageType);
            if(byteBuffer != null) buffer.put(byteBuffer);

            buffer.clear();

            dataReceived(from, buffer, skip);
        }

		public void unregister() {
			gameServer.clients.remove(getSessionId());
		}

		@Override
		public String toString() {
			return "GameClient{" +
					"sessionId=" + sessionId +
					'}';
		}
	}

	public class GameSession extends BaseUnblockingServer.Session{
		private final GameSessionClient sessionClient;

		public GameSession(GameSessionClient sessionClient) {
			this.sessionClient = sessionClient;
			this.sessionClient.setSession(this);
		}

		public GameSessionClient getGameClient() {
			return sessionClient;
		}
    }

    private final AtomicInteger freeSessionId;
	private final Map<Integer, GameClient> clients = new ConcurrentHashMap<Integer, GameClient>();
	private final BroadcastService broadcastService;
    private final ServerService serverService;
	
	public GameServer(ServerProperties serverProperties) {
		super(serverProperties);
		int id = 0;
		broadcastService = new BroadcastService(this, id++);
        serverService = new ServerService(this, id++);
		freeSessionId = new AtomicInteger(id);
	}

    public BroadcastService getBroadcastService() {
        return broadcastService;
    }

    public ServerService getServerService() {
        return serverService;
    }

    public Map<Integer, GameClient> getClients() {
        return clients;
    }

	@Override
	protected GameSession createSession() {
		log.debug("New client accepting: ");
		return new GameSession(new GameSessionClient(this));
	}

	@Override
	protected void onAccept(GameSession session) {
		GameSessionClient attachment = session.getGameClient();
		int sessionId = attachment.getSessionId();
        log.debug("New client accepted: " + sessionId + "...");
		attachment.requestSnapshot();
	}


	@Override
	protected void onDataReceived(GameSession session) {
		ByteBuffer inputBuffer = session.getInputBuffer();
		GameSessionClient from = session.getGameClient();
		log.debug("Reading session id: " + from.getSessionId());

		while (inputBuffer.remaining() > INT_SIZE) {
			int oldPosition = inputBuffer.position();

			int messageSize = inputBuffer.getInt();

            if (inputBuffer.remaining() >= messageSize){

                ByteBuffer packetBuffer = inputBuffer.duplicate();
                inputBuffer.position(inputBuffer.position() + messageSize);
                packetBuffer.limit(inputBuffer.position());

	            int receiverID = packetBuffer.getInt();
                int flag       = packetBuffer.getInt();
	            GameServer.GameClient receiver = clients.get(receiverID);

                receiver.dataReceived(from, packetBuffer, (flag & SKIP_BIT) != 0);
            }else{
	            inputBuffer.position(oldPosition);
                if(inputBuffer.limit() == inputBuffer.capacity()){
                    session.increaseBuffer();
                }
                return;
            }
        }

		from.requestSnapshot();
	}

	@Override
	protected void onClose(GameSession session) {
        GameSessionClient gameClient = session.getGameClient();
        gameClient.unregister();
        getBroadcastService().sendMessage(getServerService(), MESSAGE_TYPE_CLIENT_DISCONNECTED, ByteBuffer.wrap(Utils.toBytes(gameClient.getSessionId())));
	}
}
