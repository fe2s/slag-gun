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

package com.slaggun.util.log {
import flash.system.Capabilities;
import flash.utils.getDefinitionByName;

/**
 *
 * @author Oleksiy Dyagilev (aka.fe2s@gmail.com)
 */
public class Logger {

    private static var config:LoggerConfig = LoggerConfig.instance;

    // stacktrace format
    private static const NONE:String = "<NONE>";
    private static const STACKTRACE_PREFIX:String = "at ";
    private static const STACKTRACE_SUFFIX:String = "()";
    private static const STACKTRACE_CLASS_SPLITTER:String = "::";

    private static const STACKTRACE_PREFIX_LENGTH:int = STACKTRACE_PREFIX.length;
    private static const STACKTRACE_CLASS_SPLITTER_LENGHT:int = STACKTRACE_CLASS_SPLITTER.length;

    private var callerClass:Class;

    // full class name with package (e.g. com.slaggun::Main)
    private var callerFullClassName:String;

    private var categories:Array = [];

    public static function getLogger(clazz:Class):Logger {
        var logger:Logger = new Logger();
        logger.init(clazz);
        return logger;
    }

    public function debug(msg:String):void {
        log(msg, Priority.DEBUG);
    }

    public function info(msg:String):void {
        log(msg, Priority.INFO);
    }

    public function error(msg:String):void {
        log(msg, Priority.ERROR);
    }

    private function log(msg:String, priority:Priority):void {
        for each (var category:Category in categories) {
            if (priority.greaterOrEqualThan(category.priority)) {
                for each (var appender:Appender in category.appenders) {
                    appender.append(callerClass + ": " + msg + "\n");
                }
            }
        }
    }

    private function init(clazz:Class):void {
        this.callerClass = clazz;
        setupCategories();
    }

    private function setupCategories():void {
        for each (var category:Category in config.categories) {
            if (category.clazz == callerClass) {
                categories.push(category);
            }
        }
    }
}
}