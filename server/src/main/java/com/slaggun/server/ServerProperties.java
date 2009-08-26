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

import java.io.InputStream;
import java.util.Properties;

/**
 * Holds server properties, e.g. port number.
 *
 * @author Oleksiy Dyagilev (aka.fe2s@gmail.com)
 */
public class ServerProperties {

    private static Logger log = Logger.getLogger(ServerProperties.class);

    // properties from file
    private Properties properties;

    private static String SERVER_PROPERTIES_FILE_NAME = "config/server.properties";
    private static String SERVER_PORT_KEY = "server.port";
	private static String FLEX_POLICY_PORT_KEY = "flex.policy.port";
    private static String READ_BUFFER_SIZE_KEY = "read.buffer.size";
    private static String PACKET_HANDLERS_QUEUE_SIZE_KEY = "packet.handlers.queue.size";
    private static String OUTGOING_PACKETS_QUEUE_SIZE_KEY = "outgoing.packets.queue.size";

    private int gameServerPort;
	private int flexPolicyPort;
    private int availableProcessors;
    private int readBufferSize;
    private int packetHandlersQueueSize;
    private int outgoingPacketsQueueSize;


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
    private void readPropertiesFromFile() throws ServerInitializationException {
        // read property file
        InputStream propertiesStream = this.getClass().getResourceAsStream("/" + SERVER_PROPERTIES_FILE_NAME);
        properties = new Properties();
        try {
            properties.load(propertiesStream);
        } catch (Exception e) {
            throw new ServerInitializationException("Can't load file " + SERVER_PROPERTIES_FILE_NAME +
                    " from classpath. Probably file not found.", e);
        }

	    log.info("Loading game config");

        // get server.port property
        gameServerPort = Integer.parseInt(findProperty(SERVER_PORT_KEY));
        log.info(" server port: " + gameServerPort);

	    flexPolicyPort = Integer.parseInt(findProperty(FLEX_POLICY_PORT_KEY));
	    log.info(" flex policy port: " + flexPolicyPort);

        // get read buffer size
        readBufferSize = Integer.parseInt(findProperty(READ_BUFFER_SIZE_KEY));
        log.info(" read buffer size: " + readBufferSize);

        // get events handlers queue size
        packetHandlersQueueSize = Integer.parseInt(findProperty(PACKET_HANDLERS_QUEUE_SIZE_KEY));
        log.info(" packet handlers queue size: " + packetHandlersQueueSize);

         // get the outgoing packets queue size
        outgoingPacketsQueueSize = Integer.parseInt(findProperty(OUTGOING_PACKETS_QUEUE_SIZE_KEY));
        log.info(" outgoing packets queue size: " + outgoingPacketsQueueSize);
    }

    private String findProperty(String propertyKey) throws ServerInitializationException {
        String foundProperty = properties.getProperty(propertyKey);
        if (StringUtils.isEmpty(foundProperty)) {
            throw new ServerInitializationException("Can't find property " + propertyKey + " in file " +
                    SERVER_PROPERTIES_FILE_NAME);
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

    public int getPacketHandlersQueueSize() {
        return packetHandlersQueueSize;
    }

    public void setPacketHandlersQueueSize(int packetHandlersQueueSize) {
        this.packetHandlersQueueSize = packetHandlersQueueSize;
    }

    public int getOutgoingPacketsQueueSize() {
        return outgoingPacketsQueueSize;
    }

    public void setOutgoingPacketsQueueSize(int outgoingPacketsQueueSize) {
        this.outgoingPacketsQueueSize = outgoingPacketsQueueSize;
    }

    @Override
    public String toString() {
        return "ServerProperties{" +
                "gameServerPort=" + gameServerPort +
                ", availableProcessors=" + availableProcessors +
                '}';
    }
}
