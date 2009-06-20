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

package com.slaggun {
import com.slaggun.actor.player.simple.SimplePlayerPackage;
import com.slaggun.actor.world.InputState;
import com.slaggun.actor.world.PhysicalWorld;

import flash.display.BitmapData;
import flash.display.Graphics;
import flash.events.DataEvent;

import mx.collections.ArrayCollection;

/**
 * Lucnher class that integrates game engine and mxml
 *
 * Author Dmitry Brazhnik (amid.ukr@gmail.com) 
 *
 * @see PhysicalWorld
 */
public class LuncherClass {
    
        private var gamePaused:Boolean = true;
        private var lastTime:Date;
        private var world:PhysicalWorld = new PhysicalWorld();


        public function LuncherClass() {
        }

        /**
         * Initialize luncher settings
         * @return
         */
        public function inititalize():void {
            var actorPackage:SimplePlayerPackage = new SimplePlayerPackage();
            world.add(actorPackage.createPlayer());
            
            start();
        }

        /**
        * Start game engine simulation
        */
        private function start():void {
            lastTime = new Date();
            gamePaused = false;
        }

        /**
         * Proccess frame
         * @param g - graphics
         * @return nothing
         */
        public function enterFrame(g:Graphics):void {
            if (!gamePaused) {
                var nowTime:Date = new Date();
                var mils:Number = (nowTime.getTime() - lastTime.getTime());
                if (mils > 50)
                {
                    lastTime = nowTime;
                    world.live(mils);
                }

                var bitmapData:BitmapData = world.bitmap
                g.beginBitmapFill(bitmapData)
                g.drawRect(0, 0, bitmapData.rect.width, bitmapData.rect.height)
                g.endFill()
            }
        }

        /**
         * Handle mouse move event.
         * @param localX - x mouse coordinate
         * @param localY - y mouse coordinate
         * @return
         */
        public function mouseMove(localX:Number, localY:Number):void {
            world.inputStates.updateMousePosition(localX, localY);
        }

        /**
         * Handle keyboard/mouse press down event
         * @param keyCode - keycode
         * @see Keyboard
         */
        public function buttonDown(keyCode:Number):void {            
            world.inputStates.pressDown(keyCode)
        }

        /**
         * Handle keyboard/mouse up evemt
         * @param keyCode - key code
         * @return
         */
        public function buttonUp(keyCode:Number):void {
            world.inputStates.pressUp(keyCode)
        }

        /**
         * Handle screen resize
         * @param width - screen width
         * @param height - screen hright
         */
        public function resize(width:Number, height:Number):void {
            world.updateBitMapSize(width, height);
        }
    }
}