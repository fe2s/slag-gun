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

package com.slaggun.actor.player.simple {
import com.slaggun.actor.base.ActorModel;
import com.slaggun.log.Logger;

import flash.geom.Point;

/**
 * This is model for the SimplePlayer
 *
 * Author Dmitry Brazhnik (amid.ukr@gmail.com)
 *
 * @see SimplePlayer
 */
[RemoteClass(alias="com.slaggun.actor.player.simple.SimplePlayerModel")]
public class SimplePlayerModel implements ActorModel{

    private var log:Logger = Logger.getLogger(SimplePlayerModel);

    public var position:Point = new Point(50, 50);
    public var velocity:Point = new Point();
    public var look:Point = new Point();
    public var health:int;


    /**
     * Copy values from src to dst and returns dst
     * @param src
     * @param dst
     * @return
     */
    protected function copyValues(src:SimplePlayerModel, dst:SimplePlayerModel):SimplePlayerModel{
        dst.position = src.position.clone();
        dst.velocity = src.velocity.clone();
        dst.look = src.look.clone();
        dst.health = src.health;

        return dst;
    }

    public function clone():SimplePlayerModel {
        return copyValues(this, new SimplePlayerModel());
    }

    public function toString():String {
        return "SimplePlayerModel{_position=" + String(position) +
               ",_velocity=" + String(velocity) +
               ",_look=" + String(look) + "}";
    }
}
}