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

    private static String SERVER_PROPERTIES_FILE_NAME = "server.properties";
    private static String SERVER_PORT_KEY = "server.port";
    private static String READ_BUFFER_SIZE_KEY = "server.read.buffer.size";

    private int gameServerPort;
    private int availableProcessors;
    private int readBufferSize;


    /**
     *  Initialize server properties
     *
     * @throws ServerInitializationException -
     * @return itself
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
     * property file or reading some properties
     */
    private void readPropertiesFromFile() throws ServerInitializationException {
        // read property file
        InputStream propertiesStream = this.getClass().getResourceAsStream("/" + SERVER_PROPERTIES_FILE_NAME);
        Properties properties = new Properties();
        try {
            properties.load(propertiesStream);
        } catch (Exception e) {
            throw new ServerInitializationException("Can't load file " + SERVER_PROPERTIES_FILE_NAME +
                    " from classpath. Probably file not found.", e);
        }

        // get server.port property
        String gameServerPortStr = properties.getProperty(SERVER_PORT_KEY);
        if (StringUtils.isEmpty(gameServerPortStr)) {
            throw new ServerInitializationException("Can't find property " + SERVER_PORT_KEY + " in file " +
                    SERVER_PROPERTIES_FILE_NAME);
        }
        gameServerPort = Integer.parseInt(gameServerPortStr);
        log.info("Server port: " + gameServerPort);

        // get read buffer size
        String readBufferSizeStr = properties.getProperty(READ_BUFFER_SIZE_KEY);
        if (StringUtils.isEmpty(readBufferSizeStr)) {
            throw new ServerInitializationException("Can't find property " + SERVER_PORT_KEY + " in file " +
                    SERVER_PROPERTIES_FILE_NAME);
        }
        readBufferSize = Integer.parseInt(readBufferSizeStr);
        log.info("Read buffer size: " + readBufferSize);
    }

    public int getGameServerPort() {
        return gameServerPort;
    }

    public void setGameServerPort(int gameServerPort) {
        this.gameServerPort = gameServerPort;
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

    @Override
    public String toString() {
        return "ServerProperties{" +
                "gameServerPort=" + gameServerPort +
                ", availableProcessors=" + availableProcessors +
                '}';
    }
}
