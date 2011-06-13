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

import com.slaggun.server.BaseUnblockingServer;
import com.slaggun.server.ServerProperties;
import com.slaggun.server.GameServer;
import com.slaggun.policy.FlexPolicy;
import org.apache.log4j.Logger;


/**
 * @author Oleksiy Dyagilev (aka.fe2s@gmail.com)
 */
public class Main {

    private static final Logger log = Logger.getLogger(Main.class);

    public static void main(String[] args)  {
        Main main = new Main();
        try {
            main.start();
        } catch (Throwable e) {
            log.error("Error occurred", e);
        }
    }

    public void start() throws Exception {

        BaseUnblockingServer server;
	    FlexPolicy flexPolicy = null;
        try {
            ServerProperties serverProperties = new ServerProperties().initialize();
	        flexPolicy = new FlexPolicy(serverProperties);
	        flexPolicy.start();
            server = new GameServer(serverProperties);

	        server.start();
        } catch (Exception e) {
            throw new Exception("Error during server initialization", e);
        }finally {
	        if(flexPolicy != null)
		        flexPolicy.stop();
        }
    }

}
