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

package com.slaggun.log {
import com.slaggun.util.Storage;
import com.slaggun.util.Utils;

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

    private var configCategories:Array;

    private var callerClass:Class;

    // full class name with package (e.g. com.slaggun::Main)
    private var callerFullClassName:String;

    private var categories:Array = [];

    public static function getLogger(clazz:Class):Logger {
        var logger:Logger = new Logger();
        logger.init(clazz);
        return logger;
    }

    public function debug(msg:String, error:Error = null):void {
        log(msg, Priority.DEBUG, error);
    }

    public function info(msg:String, error:Error = null):void {
        log(msg, Priority.INFO, error);
    }

    public function warn(msg:String, error:Error = null):void {
        log(msg, Priority.WARN, error);
    }

    public function error(msg:String, error:Error = null):void {
        log(msg, Priority.ERROR, error);
    }

    public function throwError(msg:String, err:Error):void {
        error(msg, err);
        if(Capabilities.isDebugger && Storage.rethrowErrors()){
            throw err;
        }
    }

    private function log(msg:String, priority:Priority, error:Error = null):void {
        setupCategories();

        var appenders:Array = [];

        for each (var category:Category in categories) {
            if (priority.greaterOrEqualThan(category.priority)) {
                for each (var appender:Appender in category.appenders) {

                    if(appenders.indexOf(appender) != -1)
                        continue;
                    appenders.push(appender);

                    var messsage:String = priority.name + ":" + callerClass + ": " + msg;


                    if(error != null){
                        var stackTrace:String = error.getStackTrace();
                        messsage += ":     " + error.message;
                        if(stackTrace != null){
                            messsage += "\n" + stackTrace;
                        }
                    }

                    appender.append(messsage + "\n");
                }
            }
        }
    }

    private function init(clazz:Class):void {
        this.callerClass = clazz;
    }

    private static function findByClassName(clazz:Class):Array{
        var result:Array = [];
        for each (var category:Category in config.categories) {
            if (category.clazz == clazz) {
                result.push(category);
            }
        }

        return  result;
    }

    private function setupCategories():void {

        if(configCategories != config.categories){
            configCategories = config.categories;

            categories = findByClassName(callerClass);

            if(categories.length == 0){
                categories = findByClassName(RootCategory);
            }

            categories = categories.concat(findByClassName(CommonCategory));
        }
    }
}
}