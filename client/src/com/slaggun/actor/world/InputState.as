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
import flash.geom.Point;

/**
 * Holder of user input states(keyboard/mouse);
 *
 * Author Dmitry Brazhnik (amid.ukr@gmail.com)
 */
public class InputState{
        private var mouse:Point = new Point(0, 0);
        private var keyboard:Array;

        /**
         *  Scan code to check is left mouse button is clicked
         */
        public static const MOUSE_LEFT   :Number = 256;

        /**
         *  Scan code to check is right mouse button is clicked
         */
        public static const MOUSE_RIGHT  :Number = 257;
    
        private static const LAST:Number = MOUSE_RIGHT ;


        public function InputState()
        {
            keyboard = [];

            keyboard.length = LAST;

            for(var s:String in keyboard){
                keyboard[s] = false;
            }
        }

        /**
         * Press mosue/keyboard button
         * @param keyNumber - key scan code
         * @return
         */
        public function pressDown(keyNumber:Number):void{
            keyboard[keyNumber]  = true;
        }

        /**
         * Unpress mosue/keyboard button
         * @param keyNumber - key scan code
         * @return
         */
        public function pressUp(keyNumber:Number):void{
            keyboard[keyNumber]  = false;
        }

        /**
         * Set mouse coords
         * @param x - x mouse position
         * @param y - y mouse position
         * @return
         */
        public function updateMousePosition(x:Number, y:Number):void {
            mouse = new Point(x, y);
        }

        /**
         * Check whether mouse/keyboard button is pressed.
         * @param keyCode - button to be checked
         * @return true if button is checked, otherwise false
         */
        public function isPressed(keyCode: Number):Boolean{
            return keyboard[keyCode]; 
        }

        /**
         * Returns mouse position 
         * @return mouse position
         */
        public function get mousePosition():Point {
            return mouse;
        }
    }
}