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
import flash.display.BitmapData;

/**
 * @author Dmitry Brazhnik (amid.ukr@gmail.com)
 */
public class GameEvent {

    //TBD: synchronize this with game iterations and server
    public static function get time():Number{
        return new Date().time;
    }

    private var _game:Game;
    internal var _time:Timestamp;
    internal var _elapsedTime:Number;
    internal var _bitmap:BitmapData;

    public function GameEvent(game:Game) {
        this._game = game;
    }

    public function get game():Game {
        return _game;
    }

    public function nowTime():Number{
        return _time.time;
    }

    public function now():Timestamp{
        return _time.clone(_game);
    }

    public function get elapsedTime():Number {
        return _elapsedTime;
    }


    public function get bitmap():BitmapData {
        return _bitmap;
    }
}
}
