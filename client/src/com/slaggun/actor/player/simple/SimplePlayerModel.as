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
import com.slaggun.actor.player.PlayerConstants;
import com.slaggun.util.log.Logger;

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

    private var log:Logger = Logger.getLogger();

    private var _position:Point = new Point(50, 50);
    private var _velocity:Point = new Point();
    private var _look:Point = new Point();
    private var _health:int = PlayerConstants.MAX_HEALTH_HP; // in hit points

    /**
     * Hit player (decrease health)
     * 
     * @param hitPoints
     * @return true if still live, false if person has died  :)
     */
    public function hit(hitPoints:int):Boolean {
        log.info("damaged " + hitPoints);
        log.info("health " + _health);
        _health -= hitPoints;
        return _health > 0;
    }

    /**
     * Respawn player
     */
    public function respawn():void {
        log.info("respawned");
        _health = PlayerConstants.MAX_HEALTH_HP;
        _position = new Point(50, 50);
    }

    /**
     * Return player position
     * @return player position
     */
    public function get position():Point {
        return _position;
    }

    /**
     * Sets player position
     * @param value - new position
     */
    public function set position(value:Point):void {
        _position = value;
    }

    /**
     * Returns velocity vector.
     * @return velocity vector.
     */
    public function get velocity():Point {
        return _velocity;
    }

    /**
     * Sets velocity vector
     * @param value - new velocity vector
     */
    public function set velocity(value:Point):void {
        _velocity = value;
    }

    /**
     * Return vector where user look
     * @return coordinate where user look
     */
    public function get look():Point {
        return _look;
    }

    /**
     * Sets vector where user looks.
     * @param value - look coordinate
     */
    public function set look(value:Point):void {
        _look = value;
    }

    public function get health():int {
        return _health;
    }

    public function set health(value:int):void {
        _health = value;
    }

    /**
     * Copy values from src to dst and returns dst
     * @param src
     * @param dst
     * @return
     */
    protected function copyValues(src:SimplePlayerModel, dst:SimplePlayerModel):SimplePlayerModel{
        dst._position = src._position.clone();
        dst._velocity = src._velocity.clone();
        dst._look = src._look.clone();
        dst._health = src._health;

        return dst;
    }

    public function clone():SimplePlayerModel {
        return copyValues(this, new SimplePlayerModel());
    }

    public function toString():String {
        return "SimplePlayerModel{_position=" + String(_position) +
               ",_velocity=" + String(_velocity) +
               ",_look=" + String(_look) + "}";
    }
}
}