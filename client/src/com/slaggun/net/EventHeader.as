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

package com.slaggun.net {
import flash.utils.ByteArray;

/**
 * @author Oleksiy Dyagilev (aka.fe2s@gmail.com)
 */
public class EventHeader {

    public static const BINARY_SIZE:int = 4;

    private var _bodySize:int;

    public function EventHeader(bodySize:int) {
        _bodySize = bodySize;
    }

    public function get content():ByteArray {
        var content:ByteArray = new ByteArray();
        content.writeInt(_bodySize);
        return content;
    }

    public function get bodySize():int {
        return _bodySize;
    }

    public function set bodySize(value:int):void {
        _bodySize = value;
    }
}
}