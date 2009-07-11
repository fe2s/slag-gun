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

package com.slaggun.util;

import org.apache.log4j.Logger;
import org.apache.log4j.xml.DOMConfigurator;

import java.io.File;
import java.net.URL;

/**
 * @author Oleksiy Dyagilev (aka.fe2s@gmail.com)
 */
public class LoggerUtils {

    private static final String LOGGER_CONFIG_FILE = "config/log4j.xml";

    public static void initializeLogger() {
        URL loggerConfigURL = ClassLoader.getSystemResource(LOGGER_CONFIG_FILE);
        System.out.println("Initializing lo4j, reading from " + loggerConfigURL);
        DOMConfigurator.configure(loggerConfigURL);
    }

    public static <T extends Throwable> void logAndThrow(Logger logger, T throwable, String message) throws T {
        logger.error(message, throwable);
        throw throwable;
    }

    public static <T extends Throwable> void logAndThrow(Logger logger, T throwable) throws T {
        logger.error(throwable);
        throw throwable;
    }

}
