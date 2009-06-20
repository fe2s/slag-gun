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

    /**
     * This is model for the SimplePlayer
     *
     * Author Dmitry Brazhnik (amid.ukr@gmail.com)
     *
     * @see SimplePlayer
     */
    public class SimplePlayerModel implements ActorModel{

        private var _x:Number = 50;
        private var _y:Number = 50;

        private var _vx:Number;
        private var _vy:Number;

        private var _lookX:Number;
        private var _lookY:Number;


        /**
         * Returns x actor coord
         * @return x actor coord
         */
        public function get x():Number {
            return _x;
        }

        /**
         * Set x actor coord
         * @param value - new x coord value
         */
        public function set x(value:Number):void {
            _x = value;
        }

        /**
         * Returns y actor coord
         * @return y actor coord
         */
        public function get y():Number {
            return _y;
        }

        /**
         * Set y actor coord
         * @param value - new y coord value
         */
        public function set y(value:Number):void {
            _y = value;
        }

        /**
         * Returns x actor velocity
         * @return x actor velocity
         */
        public function get vx():Number {
            return _vx;
        }

        /**
         * Set x actor velocity
         * @param vx - new x actor velocity
         */
        public function set vx(vx:Number):void {
            _vx = vx;
        }

        /**
         * Returns y actor velocity
         * @return y actor velocity
         */
        public function get vy():Number {
            return _vy;
        }

        /**
         * Set y actor velocity
         * @param value - new y actor velocity
         */
        public function set vy(vy:Number):void {
            _vy = vy;
        }

        /**
         * Returns x actor look vector
         * @return x actor look vector
         */
        public function get lookX():Number {
            return _lookX;
        }


        /**
         * Set x coordinate of actor look vector
         * @param value - new x actor look vector coordinate
         */
        public function set lookX(value:Number):void {
            _lookX = value;
        }

        /**
         * Returns y actor look vector
         * @return y actor look vector
         */
        public function get lookY():Number {
            return _lookY;
        }

        /**
         * Set y coordinate of actor look vector
         * @param value - new y actor look vector coordinate
         */
        public function set lookY(value:Number):void {
            _lookY = value;
        }
    }
}