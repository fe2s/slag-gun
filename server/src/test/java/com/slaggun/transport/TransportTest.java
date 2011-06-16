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

package com.slaggun.transport;

import com.slaggun.server.GameServer;
import com.slaggun.server.ServerProperties;
import junit.framework.TestCase;

import java.io.IOException;
import java.net.Socket;
import java.nio.ByteBuffer;

/**
 * @author Dmitry Brazhnik (amid.ukr@gmail.com)
 */
public class TransportTest extends TestCase{
	private GameServer gameServer;
	private ServerProperties properties;


	private final int INT_SIZE = Integer.SIZE/8;

	private Socket createConnection() throws IOException {
		return new Socket("localhost", properties.getGameServerPort());
	}

	private Timeout timeout(String message){
		return new Timeout(message, 5000);
	}

	private class Package{
		private int sender;
		private String message;

		private Package(int sender, String message) {
			this.sender = sender;
			this.message = message;
		}

		public int getSender() {
			return sender;
		}

		public String getMessage() {
			return message;
		}
	}



	private void sendData(Socket socket, int recipient, String ... data) throws IOException {

        ByteBuffer[] byteBuffers = new ByteBuffer[data.length];

        int messageSize = 0;

        for (int i = 0; i < byteBuffers.length; i++) {
            byteBuffers[i] = ByteBuffer.wrap(data[i].getBytes());
            messageSize += byteBuffers[i].remaining() + INT_SIZE*3;
        }

		ByteBuffer sendPackage = ByteBuffer.allocate(messageSize);

        for (ByteBuffer byteBuffer : byteBuffers) {
            sendPackage.putInt(byteBuffer.remaining() + 2*INT_SIZE);
		    sendPackage.putInt(recipient);
            sendPackage.putInt(0);
		    sendPackage.put(byteBuffer);
        }

		socket.getOutputStream().write(sendPackage.array());
		socket.getOutputStream().flush();
	}

	private Package receiveData(Socket socket, Timeout timeout) throws IOException {
		while(socket.getInputStream().available() < INT_SIZE){
			timeout.assertExceed();
		}

		byte[] sizeBuffer = new byte[INT_SIZE];
		socket.getInputStream().read(sizeBuffer);
		int size = ByteBuffer.wrap(sizeBuffer).getInt();

		while(socket.getInputStream().available() < size){
			timeout.assertExceed();
		}

		ByteBuffer buffer = ByteBuffer.allocate(size);
		socket.getInputStream().read(buffer.array());

		int sender = buffer.getInt();
		String message = new String(buffer.array(), buffer.position(), buffer.remaining());

		return new Package(sender, message);
	}

	public void testBroadcast() throws IOException {
        //TODO: implement unskipable packages
		Socket sender = createConnection();
		Socket recipient1 = createConnection();
		Socket recipient2 = createConnection();

		receiveData(sender, timeout("Sender snapshot request"));
		receiveData(recipient1, timeout("Recipient 1 snapshot request"));
		receiveData(recipient2, timeout("Recipient 2 snapshot request"));
		
		final String sendDate1 = "assert me1";
        final String sendDate2 = "assert me2";
		//sendData(sender, 0, sendDate1, sendDate2);
        sendData(sender, 0, sendDate1);

		TransportTest.Package package11 = receiveData(recipient1, timeout("Read first client"));
        //TransportTest.Package package12 = receiveData(recipient1, timeout("Read first client"));

		TransportTest.Package package21 = receiveData(recipient2, timeout("Read second client"));
        //TransportTest.Package package22 = receiveData(recipient2, timeout("Read second client"));

		assertEquals("First client first message received: ", sendDate1, package11.getMessage());
        //assertEquals("First client second message received: ", sendDate2, package12.getMessage());

		assertEquals("Second client first message received: ", sendDate1, package21.getMessage());
        //assertEquals("Second client second message received: ", sendDate2, package22.getMessage());

		assertEquals("Sender id check: ", package11.getSender(), package21.getSender());
        //assertEquals("Sender id check: ", package11.getSender(), package12.getSender());
        //assertEquals("Sender id check: ", package11.getSender(), package22.getSender());
	}

	public void testSend() throws IOException, InterruptedException {
		Socket sender = createConnection();
		Socket recipient1 = createConnection();
		Socket recipient2 = createConnection();

		receiveData(sender, timeout("Sender snapshot request"));
		receiveData(recipient1, timeout("Recipient 1 snapshot request"));
		receiveData(recipient2, timeout("Recipient 2 snapshot request"));

		final String sendDate = "assert me";
		sendData(sender, 4, sendDate);


		TransportTest.Package package2 = receiveData(recipient2, timeout("Read second client"));
		assertEquals("Second message recieved: ", sendDate, package2.getMessage());

		Thread.sleep(1000);
		assertEquals("First client must be empty", 0, recipient1.getInputStream().available());
	}
	
	@Override
	protected void setUp() throws Exception {
		properties = new ServerProperties().initialize();
		gameServer = new GameServer(properties);
		new Thread("Server loop"){
			@Override
			public void run() {
				try {
					gameServer.start();
				} catch (IOException e) {
					e.printStackTrace();
				}
			}
		}.start();

		Thread.sleep(1000);
	}

	@Override
	protected void tearDown() throws Exception {
		gameServer.stop();
	}
}
