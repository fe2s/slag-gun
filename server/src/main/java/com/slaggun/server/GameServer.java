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

import com.slaggun.server.services.GameSessionClient;
import com.slaggun.server.services.ServerSide;
import org.apache.log4j.Logger;

import java.nio.ByteBuffer;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.atomic.AtomicInteger;

/**
 * @author Dmitry Brazhnik (amid.ukr@gmail.com)
 */
public class GameServer extends BaseUnblockingServer<GameServer.GameSession> {

    public static final int SKIP_BIT = 0x1;
	public static final int INT_SIZE = Integer.SIZE/8;

	private final Logger log = Logger.getLogger(GameServer.class);

    public static abstract class GameClient{
        protected final GameServer gameServer;
		private final int sessionId;
		private final Map<GameClient, Object> dataRetrieved = new ConcurrentHashMap<GameClient, Object>();

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

		protected abstract void dataReceived(GameClient from, ByteBuffer byteBuffer, boolean skipable);

		public void postData(GameClient from, ByteBuffer byteBuffer){
			postData(from, byteBuffer, false);
		}

		public void postData(GameClient from, ByteBuffer byteBuffer, boolean skip){
			if(!skip){
				dataReceived(from, byteBuffer, skip);
			}else if(!dataRetrieved.containsKey(from)){
				dataReceived(from, byteBuffer, skip);
				dataRetrieved.put(from, new Object());
			}
		}

		public void requestSnapshot(){
			dataRetrieved.clear();
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

		public GameClient getGameClient() {
			return sessionClient;
		}
	}

    private final AtomicInteger freeSessionId;
	private final Map<Integer, GameClient> clients = new ConcurrentHashMap<Integer, GameClient>();
	private final ServerSide serverSide;
	
	public GameServer(ServerProperties serverProperties) {
		super(serverProperties);
		int id = 0;
		serverSide = new ServerSide(this, id++);
		freeSessionId = new AtomicInteger(id);
	}

    public ServerSide getServerSide() {
        return serverSide;
    }

    public Map<Integer, GameClient> getClients() {
        return clients;
    }

    public void sendData(GameClient from, GameClient to, ByteBuffer data, boolean skip){

		int packetSize = INT_SIZE  + data.remaining();
		ByteBuffer sendBuffer = ByteBuffer.allocate(INT_SIZE + packetSize);
		sendBuffer.putInt(packetSize);
		sendBuffer.putInt(from.getSessionId());
		sendBuffer.put(data);
		sendBuffer.clear();

		to.postData(from, sendBuffer, skip);
	}

	public void sendDate(GameClient from, GameClient to, ByteBuffer data){
		sendData(from, to, data, false);
	}

	@Override
	protected GameSession createSession() {
		log.debug("New client accepting: ");
		return new GameSession(new GameSessionClient(this));
	}

	@Override
	protected void onAccept(GameSession session) {
		GameClient attachment = session.getGameClient();
		int sessionId = attachment.getSessionId();
        log.debug("New client accepted: " + sessionId + "...");
		attachment.requestSnapshot();
	}


	@Override
	protected void onDataReceived(GameSession session) {
		ByteBuffer inputBuffer = session.getInputBuffer();
		GameClient from = session.getGameClient();
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
	            sendData(from, receiver, packetBuffer, (flag & SKIP_BIT) != 0);
            }else{
	            inputBuffer.position(oldPosition);
                return;
            }
        }

		from.requestSnapshot();
	}

	@Override
	protected void onClose(GameSession session) {
		session.getGameClient().unregister();
	}
}
