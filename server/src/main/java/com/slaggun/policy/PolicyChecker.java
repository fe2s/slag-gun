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

import java.net.Socket;
import java.net.UnknownHostException;
import java.io.*;
import java.nio.CharBuffer;

/**
 * Requests policy file
 * @author Dmitry Brazhnik (amid.ukr@gmail.com)
 */
public class PolicyChecker {
	public static void main(String[] args) throws IOException {
		Socket socket = new Socket("127.0.0.1", 843);
		socket.getOutputStream().write("<policy-file-request/>\u0000".getBytes());
		InputStream inputStream = socket.getInputStream();
		Reader reader = new BufferedReader(new InputStreamReader(inputStream));
		char[] chars = new char[1024];
		int size = reader.read(chars);
		System.out.println("chars = " + new String(chars, 0, size));
	}
}
