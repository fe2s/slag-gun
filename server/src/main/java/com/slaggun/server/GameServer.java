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

import org.apache.log4j.Logger;

import java.nio.ByteBuffer;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.atomic.AtomicInteger;

/**
 * @author Dmitry Brazhnik (amid.ukr@gmail.com)
 */
public class GameServer extends BaseUnblockedServer<GameServer.GameSession> {

	private final int INT_SIZE = Integer.SIZE/8;

	private Logger log = Logger.getLogger(GameServer.class);

    public abstract class GameClient{
		private final int sessionId;
		private Map<GameClient, Object> dataRetrieved = new ConcurrentHashMap<GameClient, Object>();

		protected GameClient() {
			this(freeSessionId.getAndIncrement());
		}

		public GameClient(int id) {
			sessionId = id;
			clients.put(sessionId, this);
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
			clients.remove(getSessionId());
		}

		@Override
		public String toString() {
			return "GameClient{" +
					"sessionId=" + sessionId +
					'}';
		}
	}

	public class GameSession extends BaseUnblockedServer.Session{
		private final GameSessionClient sessionClient;

		public GameSession(GameSessionClient sessionClient) {
			this.sessionClient = sessionClient;
			this.sessionClient.setSession(this);
		}

		public GameClient getGameClient() {
			return sessionClient;
		}
	}

	public class GameSessionClient extends GameClient{
		private GameSession session;

		public void requestSnapshot(){
			ByteBuffer requestSnapshotEvent = ByteBuffer.allocate(INT_SIZE);
			requestSnapshotEvent.putInt(0);
			requestSnapshotEvent.clear();

			sendDate(serverSide, this, requestSnapshotEvent);

			super.requestSnapshot();
		}

		@Override
		protected void dataReceived(GameClient from, ByteBuffer byteBuffer, boolean skipable) {
			getSession().postBuffer(byteBuffer);
		}

		public GameSession getSession() {
			return session;
		}

		public void setSession(GameSession session) {
			this.session = session;
		}
	}

	public class ServerSide extends GameClient{

		public ServerSide(int id) {
			super(id);
		}

		@Override
		protected void dataReceived(GameClient from, ByteBuffer byteBuffer, boolean skipable) {
	        for (GameClient receiver : clients.values()) {
			    // otherSession can be null if it deatached due to concurrecny
			    if(receiver != null
			    && receiver != from
			    && receiver != this){
				    receiver.postData(from, byteBuffer.slice(), skipable);
				}
	        }
		}

		@Override
		public void postData(GameClient from, ByteBuffer byteBuffer, boolean skip) {
			dataReceived(from, byteBuffer, skip);
		}
	}

	private final AtomicInteger freeSessionId;
	private final Map<Integer, GameClient> clients = new ConcurrentHashMap<Integer, GameClient>();
	private final ServerSide serverSide;
	
	public GameServer(ServerProperties serverProperties) {
		super(serverProperties);
		int id = 0;
		serverSide = new ServerSide(id++);
		freeSessionId = new AtomicInteger(id);
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
		return new GameSession(new GameSessionClient());
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


		final int PACKET_HEADER_SIZE = INT_SIZE;

		while (inputBuffer.remaining() > PACKET_HEADER_SIZE ) {
			int oldPosition = inputBuffer.position();

			int messageSize = inputBuffer.getInt();

            if (inputBuffer.remaining() >= messageSize){

	            ByteBuffer packetBuffer = ByteBuffer.allocate(messageSize);
	            packetBuffer.put(inputBuffer);
	            packetBuffer.clear();

	            int receiverID = packetBuffer.getInt();
	            GameServer.GameClient receiver = clients.get(receiverID);
	            sendData(from, receiver, packetBuffer, true);
            }else{
	            inputBuffer.position(oldPosition);
            }
        }

		from.requestSnapshot();
	}

	@Override
	protected void onClose(GameSession session) {
		session.getGameClient().unregister();
	}
}
