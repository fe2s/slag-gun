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

package com.slaggun.actor.world {
import com.slaggun.actor.base.Actor;

import flash.display.BitmapData;
import flash.geom.Rectangle;

    /**
     * This is core world engine class
     *
     * Author Dmitry Brazhnik (amid.ukr@gmail.com)
     */
    public class PhysicalWorld {

        private var _inputStates:InputState = new InputState()
        private var _bitmap:BitmapData;
    
        private var actors:Array = [];

        private var toBeAdded:Array = [];
        private var toBeRemoved:Array = [];

        public function PhysicalWorld() {
        }

        /**
         * Recreate offscreen buffer
         * @param width - screen width
         * @param height - screen height
         */
        public function updateBitMapSize(width:Number, height:Number):void{
            _bitmap = new BitmapData(width, height);
        }

        /**
         * Add actor to the world.
         * If actor is adding during loop it will be active in the next loop
         * @param actor
         * @return
         */
        public function add(actor:Actor):void {
            toBeAdded.push(actor)
        }

        /**
         * Remove actor to the world.
         * If actor is removing during loop it will be remove in the next loop
         * @param actor
         * @return
         */
        public function remove(actor:Actor):void {
            toBeRemoved.push(actor)
        }

        /**
         * Returns input states
         * @return input states
         * @see InputState
         */
        public function get inputStates():InputState
        {
            return _inputStates;
        }

        /**
         * Returns offscreen buffer
         * @return offscreen buffer
         */
        public function get bitmap():BitmapData {
            return _bitmap;
        }

        /**
         * Add all actors that are waiting
         */
        private function addAll():void {

            var actorName:String;

            for (actorName in toBeAdded)
            {
                actors.push(toBeAdded[actorName])
            }

            toBeAdded = []

            for (actorName in toBeRemoved)
            {
                var actor:Actor = toBeRemoved[actorName]
                var actorIndex:Number = toBeRemoved.indexOf(actor)
                actors.push(toBeRemoved[actorIndex])
            }

            toBeRemoved = []
        }

        /**
         *
         * Proccess worl live iteration
         */
        public function live(deltaTime:Number):void {
            addAll()

            var actorName:String;
            var actor:Actor;

            for (actorName in actors)
            {
                actor = actors[actorName]
                actor.physics.live(deltaTime, actor, this)
            }

            _bitmap.fillRect(_bitmap.rect, 0xFFFFFF)

            for (actorName in actors)
            {
                actor = actors[actorName]
                actor.renderer.draw(deltaTime, actor, _bitmap);
            }
        }
    }
}