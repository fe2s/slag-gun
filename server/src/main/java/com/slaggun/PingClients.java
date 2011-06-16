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

package com.slaggun;

import com.slaggun.server.GameServer;
import org.apache.log4j.Logger;

/**
 * @author: Dmitry Brazhnik (amid.ukr@gmail.com)
 */
public class PingClients{
    private static final Logger LOGGER = Logger.getLogger(PingClients.class);

    private final GameServer gameServer;
    private boolean run = true;
    private Thread thread = new Thread(){
        @Override
        public void run() {
            while (run){
                try{

                    gameServer.getServerService().echo(gameServer.getBroadcastService(), "Ping all");

                    try {
                        Thread.sleep(5000);
                    } catch (InterruptedException e) {
                    }
                }catch (RuntimeException e){
                    LOGGER.error(e.getMessage(), e);
                }
            }
        }
    };

    public PingClients(GameServer gameServer, boolean daemon) {
        this.gameServer = gameServer;
        thread.setDaemon(daemon);
    }

    public PingClients(GameServer gameServer) {
        this(gameServer, true);
    }

    public void start(){
        run = true;
        thread.start();
    }

    public void stop(){
        run = false;
        thread.interrupt();
    }
}
