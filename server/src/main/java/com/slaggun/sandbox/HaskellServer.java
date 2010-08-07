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

package com.slaggun.sandbox;

import java.net.ServerSocket;
import java.net.Socket;
import java.io.*;

/**
 * A simple TCP server to test Haskell client
 *
 * @author Oleksiy Dyagilev (aka.fe2s@gmail.com)
 */
public class HaskellServer {

    public static void main(String[] args) throws IOException {

        ServerSocket serverSocket = new ServerSocket(5555);
        while (true){
            try {
                Socket clientSocket = serverSocket.accept();

                BufferedReader in = new BufferedReader(new InputStreamReader(clientSocket.getInputStream()));
                BufferedWriter out = new BufferedWriter(new OutputStreamWriter(clientSocket.getOutputStream()));

                String inputLine;
                while ((inputLine = in.readLine()) != null) {
                    System.out.println(inputLine);
                    out.write("Reply from Java: " + inputLine + "\n");
                    out.flush();
                }
            } catch (IOException e) {
                System.out.println(e);
            } 
        }

    }


}
