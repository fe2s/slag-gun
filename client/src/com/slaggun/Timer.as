/* Copyright 2011 SlagGunTeam
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
 * Unless required by applicable law or agreed to in writing, software distributed under the
 * License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND,
 * either express or implied. See the License for the specific language governing permissions
 * and limitations under the License.
 */
package com.slaggun {
/**
 * @author Dmitry Brazhnik (amid.ukr@gmail.com)
 */
[RemoteClass(alias="com.slaggun.Timer")]
public class Timer {
    public var _elapsedTime: Number = 0;
    public var _currentTime: Number = Game.time;

    /**
     * @return elapse time
     */
    public function mark():Number{
        return elapsedTime();
    }

    // DO NOT MAKE, PROPERTY AS AMF SERIALIZATOR WILL INVOKE THIS METHOD
    public function elapsedTime():Number {
        if(_currentTime != Game.time){
            _elapsedTime = Game.time - _currentTime;
            _currentTime = Game.time;
        }
        return _elapsedTime;
    }

    public function get time():Number{
        return Game.time;
    }

    public function clone():Timer {
        var result:Timer = new Timer();
        result._elapsedTime = this._elapsedTime;
        result._currentTime = this._currentTime;
        return result;
    }
}
}
