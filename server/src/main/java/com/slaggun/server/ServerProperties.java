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

import org.apache.commons.lang.StringUtils;
import org.apache.log4j.Logger;

import java.io.IOException;
import java.io.InputStream;
import java.util.Properties;

/**
 * Holds server properties, e.g. port number.
 *
 * @author Oleksiy Dyagilev (aka.fe2s@gmail.com)
 */
public class ServerProperties {

    private static final Logger log = Logger.getLogger(ServerProperties.class);

    // properties from file
    private Properties properties;

    private static final String SERVER_PROPERTIES_FILE_NAME = "config/server.properties";
    private static final String SERVER_PORT_KEY = "server.port";
	private static final String FLEX_POLICY_PORT_KEY = "flex.policy.port";
    private static final String MAX_BUFFER_SIZE_KEY = "max.buffer.size";
    private static final String READ_BUFFER_SIZE_KEY = "read.buffer.size";
    private static final String PACKET_HANDLERS_QUEUE_SIZE_KEY = "packet.handlers.queue.size";
    private static final String DEBUG_ARTIFICIAL_LAGS = "debug.artificial.lags";

    private int gameServerPort;
	private int flexPolicyPort;
    private int availableProcessors;
    private int readBufferSize;
    private int maxBufferSize;
    private int packetHandlersQueueSize;
    private int debugArtificialLags;


    /**
     * Initialize server properties
     *
     * @return itself
     * @throws ServerInitializationException -
     */
    public ServerProperties initialize() throws ServerInitializationException {
        readPropertiesFromFile();

        availableProcessors = Runtime.getRuntime().availableProcessors();
        log.info("Available processors: " + availableProcessors);
        return this;
    }

    /**
     * Load server properties from file.
     *
     * @throws ServerInitializationException problems with loading
     *                                       property file or reading some properties
     */
    private void readPropertiesFromFile(){
        // read property file
        InputStream propertiesStream = this.getClass().getResourceAsStream("/" + SERVER_PROPERTIES_FILE_NAME);
        properties = new Properties();
        try {
            properties.load(propertiesStream);
        } catch (IOException e) {
            throw new ServerInitializationException("Can't load file " + SERVER_PROPERTIES_FILE_NAME +
                    " from classpath. Probably file not found.", e);
        }

	    log.info("Loading game config");

        // get server.port property
        gameServerPort = getInt(SERVER_PORT_KEY, 4001);
        log.info(" server port: " + gameServerPort);

	    flexPolicyPort = getInt(FLEX_POLICY_PORT_KEY, 843);
	    log.info(" flex policy port: " + flexPolicyPort);

        // get read buffer size
        readBufferSize = getInt(READ_BUFFER_SIZE_KEY, 2048);
        log.info(" read buffer size: " + readBufferSize);

        // get read buffer size
        maxBufferSize = getInt(MAX_BUFFER_SIZE_KEY, readBufferSize * 10);
        log.info(" read buffer size: " + maxBufferSize);

        // get events handlers queue size
        packetHandlersQueueSize = getInt(PACKET_HANDLERS_QUEUE_SIZE_KEY, 100);
        log.info(" packet handlers queue size: " + packetHandlersQueueSize);

        debugArtificialLags = getInt(DEBUG_ARTIFICIAL_LAGS, 0);
        log.info(" Debug Artificial lags: " + debugArtificialLags);
        if(debugArtificialLags != 0){
            log.warn("Debug Artificial lags is enabled. Set" + DEBUG_ARTIFICIAL_LAGS + " to zero.");
        }
    }

    private Integer getInt(String propertyKey, Integer defaultValue) {
        return Integer.parseInt(get(propertyKey, defaultValue == null? null : defaultValue.toString()));
    }

    private String get(String propertyKey, String defaultValue) {
        String foundProperty = properties.getProperty(propertyKey);
        if (foundProperty == null || StringUtils.isEmpty(foundProperty)) {
            return defaultValue;
        }
        return foundProperty;
    }

    public int getGameServerPort() {
        return gameServerPort;
    }

    public void setGameServerPort(int gameServerPort) {
        this.gameServerPort = gameServerPort;
    }

	public int getFlexPolicyPort() {
		return flexPolicyPort;
	}

	public void setFlexPolicyPort(int flexPolicyPort) {
		this.flexPolicyPort = flexPolicyPort;
	}

	public int getAvailableProcessors() {
        return availableProcessors;
    }

    public void setAvailableProcessors(int availableProcessors) {
        this.availableProcessors = availableProcessors;
    }

    public int getReadBufferSize() {
        return readBufferSize;
    }

    public void setReadBufferSize(int readBufferSize) {
        this.readBufferSize = readBufferSize;
    }

    public int getMaxBufferSize() {
        return maxBufferSize;
    }

    public void setMaxBufferSize(int maxBufferSize) {
        this.maxBufferSize = maxBufferSize;
    }

    public int getPacketHandlersQueueSize() {
        return packetHandlersQueueSize;
    }

    public void setPacketHandlersQueueSize(int packetHandlersQueueSize) {
        this.packetHandlersQueueSize = packetHandlersQueueSize;
    }

    public int getDebugArtificialLags() {
        return debugArtificialLags;
    }

    public void setDebugArtificialLags(int debugArtificialLags) {
        this.debugArtificialLags = debugArtificialLags;
    }

    @Override
    public String toString() {
        return "ServerProperties{" +
                "gameServerPort=" + gameServerPort +
                ", availableProcessors=" + availableProcessors +
                '}';
    }
}
