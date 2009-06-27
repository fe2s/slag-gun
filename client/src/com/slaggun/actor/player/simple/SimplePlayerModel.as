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

import flash.geom.Point;

/**
     * This is model for the SimplePlayer
     *
     * Author Dmitry Brazhnik (amid.ukr@gmail.com)
     *
     * @see SimplePlayer
     */
    public class SimplePlayerModel implements ActorModel{

        private var _position:Point = new Point(50, 50);
        private var _velocity:Point = new Point;
        private var _look:Point     = new Point;


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
         * Return coordinate where user look
         * @return coordinate where user look
         */
        public function get look():Point {
            return _look;
        }

        /**
         * Sets coordinate where user looks.
         * @param value - look coordinate
         */
        public function set look(value:Point):void {
            _look = value;
        }
    }
}