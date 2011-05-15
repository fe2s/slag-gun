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
import com.slaggun.Game;
import com.slaggun.LauncherClass;
import com.slaggun.actor.player.simple.SimplePlayerModel;
import com.slaggun.actor.player.simple.SimplePlayerPhysics;

import com.slaggun.GameNetworking;

import mx.controls.TextArea;

/**
 * Inspired by Log4j
 * Doesn't support the hierarchy of categories.
 *
 * @author Oleksiy Dyagilev (aka.fe2s@gmail.com)
 */
public class LoggerConfig {

    private static const _instance:LoggerConfig = new LoggerConfig();

    // appenders
    private var consoleAppender:ConsoleAppender = new ConsoleAppender();
    private var textAreaAppender:TextAreaAppender = new TextAreaAppender(null);


    // modify this to configure logging
    private var _categories:Array = [
        new Category(LauncherClass, Priority.ERROR, [consoleAppender, textAreaAppender]),
        new Category(SimplePlayerPhysics, Priority.DEBUG, [textAreaAppender]),
        new Category(SimplePlayerModel, Priority.INFO, [textAreaAppender]),
        new Category(GameNetworking, Priority.DEBUG, [consoleAppender]),
        new Category(Game, Priority.DEBUG, [consoleAppender]),
    ];

    public static function get instance():LoggerConfig {
        return _instance;
    }

    public function setTextArea(textArea:TextArea):void {
        _instance.textAreaAppender.textArea = textArea;
    }

    public function get categories():Array {
        return _categories;
    }

}
}