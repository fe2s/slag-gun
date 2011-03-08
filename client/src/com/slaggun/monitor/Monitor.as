/*
 * Copyright 2011 SlagGunTeam
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
 * Unless required by applicable law or agreed to in writing, software distributed under the
 * License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND,
 * either express or implied. See the License for the specific language governing permissions
 * and limitations under the License.
 */

/**
 * Author: Dmitry Brazhnik
 */
package com.slaggun.monitor {
import com.slaggun.Monitors;
import com.slaggun.util.Utils;

public class Monitor {

    private var _initialized:Boolean = false;
    private var _name:String;
    private var _values:Array;
    private var _position:int = 0;
    private var _size:int = 0;
    private var _metaData:*;

    public function Monitor(data:*) {
        this._name = data.name;
        MonitorContainer.instance.registerMonitor(this);
        _values = new Array(Utils.getDefault(data.size, 20));
        _metaData = data;
    }

    public function get name():String{
        return _name;
    }

    public function get value():*{
        if(!_initialized){
            _values[_position] = prepareValue();
            _initialized = true;
        }

        return _values[_position];
    }

    public function set value(value:*):void{
        _initialized = true;
        _values[_position] = value;
    }

    public function appendValue(value:*):void{
        _values[_position] = value;
        _position = (_position + 1) % _values.length;
        if(_size < _values.length)
            _size++;
    }

    protected function prepareValue():*{
        return null;
    }

    public function commit():void{
        appendValue(value);
        _initialized = false;
    }

    public function get values():Array{
        return _values;
    }

    public function get size():int{
        return _size;
    }

    public function get position():int{
        return _position;
    }

    public function get metaData():*{
        return _metaData;
    }
}
}
