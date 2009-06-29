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

package com.slaggun;

import com.slaggun.events.HzEvent;
import com.slaggun.events.EventHeader;
import com.slaggun.amf.AmfSerializer;
import com.slaggun.amf.Amf3Factory;
import com.slaggun.amf.AmfSerializerException;

import java.io.*;
import java.net.InetAddress;
import java.net.Socket;

/**
 * @author Oleksiy Dyagilev (aka.fe2s@gmail.com)
 */
public class Client {
    public static void main(String[] args) throws IOException, AmfSerializerException {
        Socket socket = new Socket(InetAddress.getLocalHost(), 4001);
        OutputStream out = socket.getOutputStream();
        InputStream in = socket.getInputStream();

        int i = 1;
        boolean running = true;
        AmfSerializer serializer = Amf3Factory.instance().getAmfSerializer();

        while(running){
            HzEvent event = new HzEvent(i, i);
            byte[] eventBodyBytes = serializer.toAmfBytes(event);
            EventHeader eventHeader = new EventHeader(eventBodyBytes.length);

            out.write(eventHeader.getContent());
            out.write(eventBodyBytes);

            out.flush();
            i++;
        }

        in.close();
        out.close();
        socket.close();

//        ServerSocket serverSocket = new ServerSocket(4001);
//        Socket socket = serverSocket.accept();
//        int i = socket.getInputStream().read();
//        System.out.println(i);
    }
}
