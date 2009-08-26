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

package com.slaggun.policy;

import com.slaggun.server.ServerInitializationException;
import com.slaggun.server.ServerProperties;
import com.slaggun.util.LoggerUtils;
import com.slaggun.util.Utils;
import org.apache.log4j.Logger;

import java.io.*;
import java.net.ServerSocket;
import java.net.Socket;
import java.net.SocketException;
import java.text.MessageFormat;

/**
 * This is policy server for the flex application.
 *
 * @author Dmitry Brazhnik (amid.ukr@gmail.com)
 */
public class FlexPolicy {
	private static Logger LOGGER = Logger.getLogger(FlexPolicy.class);
	private static final String POLICY_FILE = "/com/slaggun/policy/policy.xml";

	private static final String REQUEST_POLICY_COMMAND = "<policy-file-request/>\0";

	private final ServerProperties serverProperties;
	private final byte[] responseXMLMessage;
	private final byte[] responseErrorMessage = "Bad command retrieved".getBytes();

	private PolicyThread thread;

	public FlexPolicy(ServerProperties serverProperties) {
		this.serverProperties = serverProperties;

		String xmlPattern = Utils.readFromStream(FlexPolicy.class.getResourceAsStream(POLICY_FILE));
		String xml = MessageFormat.format(xmlPattern, String.valueOf(serverProperties.getGameServerPort()));
		responseXMLMessage = xml.getBytes();
	}

	private void handle(Socket sessionSocket) throws IOException {
		String request = null;
		try {
			InputStream inputStream = sessionSocket.getInputStream();

			byte[] buff = new byte[4096];
			int size = inputStream.read(buff);

			if (size != -1) {
				request = new String(buff, 0, size);

				if (REQUEST_POLICY_COMMAND.equals(request)) {
					sessionSocket.getOutputStream().write(responseXMLMessage);
				} else {
					LOGGER.warn("Unknown command retrieved: " + request);
					sessionSocket.getOutputStream().write(responseErrorMessage);
				}
			}

		} catch (RuntimeException e) {
			throw new RuntimeException("Unexpected exception occurred" + ", request = " + request, e);
		} finally {
			if (sessionSocket != null && !sessionSocket.isClosed()) {
				sessionSocket.close();
			}
		}
	}

	private class PolicyThread extends Thread {
		private ServerSocket socket;

		private PolicyThread() {
			super("Policy server thread");
		}

		@Override
		public void run() {
			LOGGER.info("Flex policy server started");

			synchronized (this){
				notify();
			}

			do {
				try {
					handle(socket.accept());
				} catch (IOException e) {
					if (!socket.isClosed())
						LOGGER.error("Error while proccessing policy request", e);
				} catch (RuntimeException e) {
					LOGGER.error(e.getMessage(), e);
				}
			} while (!socket.isClosed());

			LOGGER.info("Flex policy server shutdown");
		}

		public void doStart() throws IOException {
			socket = new ServerSocket(serverProperties.getFlexPolicyPort());

			synchronized (this){
				start();
				try {
					wait();
				} catch (InterruptedException e) {}
			}

		}

		public void doStop() throws IOException {
			this.socket.close();
		}
	}

	public void start() throws IOException {
		if (thread == null) {
			thread = new PolicyThread();
			thread.doStart();
		}
	}

	public void stop() throws IOException {
		if (thread != null) {
			thread.doStop();
			thread = null;
		}
	}

	public void stopAndWait() throws InterruptedException, IOException {
		if (thread != null) {
			thread.doStop();
			thread.join();
			thread = null;
		}
	}

	public void stopAndWait(long mils) throws InterruptedException, IOException {
		if (thread != null) {
			thread.doStop();
			thread.join(mils);
			thread = null;
		}
	}

	public void stopAndWait(long mils, int nanos) throws InterruptedException, IOException {
		if (thread != null) {
			thread.doStop();
			thread.join(mils, nanos);
			thread = null;
		}
	}

	private static void check(FlexPolicy flexPolicy) throws IOException, InterruptedException {
		System.out.println("Check:");
		flexPolicy.start();
		flexPolicy.stopAndWait();
	}

	public static void main(String[] args) throws ServerInitializationException, IOException, InterruptedException {
		LoggerUtils.initializeLogger();

		ServerProperties serverProperties = new ServerProperties().initialize();

		FlexPolicy flexPolicy = new FlexPolicy(serverProperties);


		for (int i = 0; i < 10; i++)
			check(flexPolicy);

		System.out.println("Start:");
		flexPolicy.start();
		System.out.println("Having started");
		flexPolicy.start();
		flexPolicy.start();
		flexPolicy.start();

		System.out.println("Sending ping:");
		//test ping
		Socket socket = new Socket("localhost", serverProperties.getFlexPolicyPort());
		socket.close();

		System.out.println("Sending illegal message:");
		socket = new Socket("localhost", serverProperties.getFlexPolicyPort());
		socket.getOutputStream().write("Illegal test message".getBytes());
		socket.getOutputStream().flush();
		byte[] buff = new byte[4096];
		int size = socket.getInputStream().read(buff);
		System.out.println("Error message = " + new String(buff, 0, size));

		System.out.println();
		System.out.println("Press enter to stop server");
		System.in.read();

		System.out.println("Stop:");
		flexPolicy.stopAndWait();
		System.out.println("Having stoped:");
		flexPolicy.stop();
		flexPolicy.stop();
		flexPolicy.stop();
		flexPolicy.stop();
		flexPolicy.stopAndWait();
	}
}
