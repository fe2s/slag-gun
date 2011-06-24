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

package com.slaggun.util {
import flash.net.SharedObject;

/**
 * @author Dmitry Brazhnik (amid.ukr@gmail.com)
 */
public class Storage {
    public function Storage() {
    }

    private static function getStorage():SharedObject{
        var so:SharedObject = SharedObject.getLocal("userData");
        return so;
    }

    protected static function get(name:String, defaultValue:*):Boolean{
        var val:* = getStorage().data[name];
        return val == null ? defaultValue : val;
    }

    protected static function set(name:String, val:*):void{
        var storage:SharedObject = getStorage();
        storage.data[name] = val;
        storage.flush();
    }

    public static function rethrowErrors():Boolean{
        return get("rethrowErrors", false);
    }

    public static function setRethrowErrors(val:Boolean):void{
        set("rethrowErrors", val);
    }
}
}
