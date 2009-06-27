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

/**
     * This is core world engine class
     *
     * Author Dmitry Brazhnik (amid.ukr@gmail.com)
     */
    public class PhysicalWorld {

        private var _inputStates:InputState = new InputState();
        private var _bitmap:BitmapData;
    
        private var actors:Array = [];

        private var toBeAdded:Array = [];
        private var toBeRemoved:Array = [];

        private var _worldWidth:Number;
        private var _worldHeight:Number;


        public function PhysicalWorld() {
        }

        /**
         * Recreate offscreen buffer
         * @param width - screen width
         * @param height - screen height
         */
        public function updateBitMapSize(width:Number, height:Number):void{
            _bitmap = new BitmapData(width, height);
            _worldWidth = width;
            _worldHeight = height;
        }

        /**
         * Returns world width 
         * @return world width
         */
        public function get width():Number {
            return _worldWidth;
        }

        /**
         * Returns world height
         * @return world height
         */
        public function get height():Number {
            return _worldHeight;
        }

        /**
         * Add actor to the world.
         * If actor is adding during loop it will be active in the next loop
         * @param actor
         * @return
         */
        public function add(actor:Actor):void {            
            toBeAdded.push(actor);
        }

        /**
         * Remove actor to the world.
         * If actor is removing during loop it will be remove in the next loop
         * @param actor
         * @return
         */
        public function remove(actor:Actor):void {
            toBeRemoved.push(actor);
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

            var len:int = toBeAdded.length;
            var i:int;

            for (i = 0; i < len; i++)
            {
                actors.push(toBeAdded[i]);
            }

            toBeAdded = [];

            len = toBeRemoved.length;
            for (i = 0; i < len; i++)
            {
                var actor:Actor = toBeRemoved[i];
                var actorIndex:Number = actors.indexOf(actor);
                actors.splice(actorIndex, 1);
            }

            toBeRemoved = [];
        }

        /**
         * Proccess worl live iteration
         * @param deltaTime - time pass
         */
        public function live(deltaTime:Number):void {
            addAll();

            var actorName:String;
            var actor:Actor;

            var i:int;

            var len:int = actors.length;
            for (i = 0; i < len; i++)
            {
                actor = actors[i];
                actor.physics.live(deltaTime, actor, this);
            }

            _bitmap.fillRect(_bitmap.rect, 0xFFFFFF);            

            len = actors.length;
            for (i = 0; i < len; i++)
            {
                actor = actors[i];
                actor.renderer.draw(deltaTime, actor, _bitmap);
            }
        }
    }
}