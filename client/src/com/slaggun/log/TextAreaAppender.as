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
import mx.controls.TextArea;

/**
 *
 * @author Oleksiy Dyagilev (aka.fe2s@gmail.com)
 * @author Dmitry Brazhnik (amid.ukr@gmail.com)
 */
public class TextAreaAppender implements Appender{

    public static const CONSOLE_BUFFER_SIZE:int = 30 * 1024;

    private var buffer:Array = [""];
    private var text:String = "";

    private var _textArea:TextArea;

    public function TextAreaAppender(textArea:TextArea) {
        _textArea = textArea;
    }

    public function set textArea(value:TextArea):void {
        _textArea = value;
        text = value.text + text;
    }

    public function append(str:String):void {

        text += str;
        if((buffer.length + 1)*text.length > CONSOLE_BUFFER_SIZE){
            for(var i:int = 0; i < buffer.length - 1; i++)
            {
                buffer[i] = buffer[i + 1];
            }
            buffer[i] = text;
            text = "";
        }

        var scrolledDown:Boolean = _textArea.verticalScrollPosition + 10 >= _textArea.maxVerticalScrollPosition;

        _textArea.text = buffer.join("") + text;

        if(scrolledDown){
            _textArea.callLater(function():void{
                _textArea.verticalScrollPosition = _textArea.maxVerticalScrollPosition;
            })
        }
    }
}
}