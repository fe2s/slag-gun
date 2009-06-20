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

package com.slaggun.amf {
/**
 * @author Oleksiy Dyagilev (aka.fe2s@gmail.com)
 */

[Bindable]
[RemoteClass(alias="com.slaggun.amf.SerializeTestBean")]
public class SerializeTestBean {

    private var _name:String;
    private var _age:int;

    public function SerializeTestBean() {
    }

    public function get name():String {
        return _name;
    }

    public function set name(value:String):void {
        _name = value;
    }

    public function get age():int {
        return _age;
    }

    public function set age(value:int):void {
        _age = value;
    }
    
}
}