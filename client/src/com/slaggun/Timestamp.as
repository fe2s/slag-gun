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
public class Timestamp {
    public var time: Number;

    public function Timestamp(game:Game = null) {
        setDate(new Date(), game);
    }

    public function elapsedTime(event:GameEvent):Number {
        return event.nowTime() - time;
    }

    public final function setDate(date:Date, game:Game):Number{
        var oldTime:Number = time;
        this.time = date.getTime();
        return this.time - oldTime;
    }

    public function clone(game:Game): Timestamp{
        var time:Timestamp =  new Timestamp(game);
        time.time = this.time;
        return time;
    }
}
}
