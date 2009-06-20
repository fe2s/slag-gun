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
import com.slaggun.actor.base.Actor;
import com.slaggun.actor.base.ActorRenderer;

import flash.display.BitmapData;
import flash.display.Shape;
import flash.geom.Matrix;
import flash.geom.Point;

    /**
     * This is renderer for the SimplePlayer
     *
     * Author Dmitry Brazhnik (amid.ukr@gmail.com)
     *
     * @see SimplePlayer
     */
    public class SimplePlayerRenderer implements ActorRenderer{

        private var triangleBlue:Shape = new Shape();
        private var triangleRed:Shape = new Shape();

        private var xFrame:Number = 0;
        private var yFrame:Number = Math.PI/3;

        private static const SIZE:Number = 10.0;
        private static const H:Number = 1.7*SIZE;
        private static const YSTART:Number = SIZE*0.6;

        public function SimplePlayerRenderer(){
            triangleBlue = new Shape();
            triangleRed = new Shape();

            triangleBlue.graphics.beginFill(0x000000FF)
            triangleBlue.graphics.lineStyle(1, 0x0000AA)

            triangleRed.graphics.beginFill(0xFF0000)
            triangleRed.graphics.lineStyle(1, 0xAA0000)

            buildShape(triangleBlue);
            buildShape(triangleRed);
        }

        private static function buildShape(trinalge:Shape):void{

            trinalge.graphics.moveTo(    0, -H + YSTART)
            trinalge.graphics.lineTo (SIZE,    + YSTART)
            trinalge.graphics.lineTo(-SIZE,    + YSTART)
        }

        /**
         * Draw foots
         * @param deltaTime - time pasts
         * @param model     - actor model
         * @param bitmap    - offscreen buffer
         */
        private function drawLow(deltaTime:Number, model:SimplePlayerModel, bitmap:BitmapData):void {
            var matrix:Matrix = new Matrix();

            xFrame+=model.vx*deltaTime*0.00005
            yFrame+=model.vy*deltaTime*0.00005

            if(yFrame > 2*Math.PI )
            {
                yFrame -= 2*Math.PI
            }

            if(yFrame < 0 )
            {
                yFrame += 2*Math.PI
            }

            var triangleShape:Shape;

            if((yFrame < Math.PI/2) || (yFrame > 3*Math.PI/2)){
                triangleShape = triangleBlue
            }else{
                triangleShape = triangleRed
            }

            matrix.rotate(xFrame)
            matrix.scale(1, Math.cos(yFrame))
            matrix.scale(0.2*Math.sin(-yFrame)+1.0, 1)            
            matrix.translate(model.x, model.y-YSTART)

            bitmap.draw(triangleShape, matrix)
        }

        /**
         * Draw body
         * @param deltaTime - time pasts
         * @param model     - actor model
         * @param bitmap    - offscreen buffer
         * @return
         */
        private function drawMedium(deltaTime:Number, model:SimplePlayerModel, bitmap:BitmapData):void {
            var matrix:Matrix = new Matrix();


            // draw triangle
            var point:Point = new Point(model.lookX, model.lookY + YSTART + SIZE);
            var length:Number = point.length;            
            point.x /= length
            point.y /= length

            var angle:Number = point.x*Math.PI/2;

            matrix.scale(Math.cos(angle),1)
            matrix.translate(model.x , model.y - YSTART - SIZE)

            bitmap.draw(triangleBlue, matrix);

            var gun:Shape = new Shape();

            gun.graphics.lineStyle(3, 0)
            gun.graphics.moveTo(0,0)
            gun.graphics.lineTo(2*SIZE*point.x, 2*SIZE*point.y)

            // draw cannon
            matrix = new Matrix();

            matrix.translate(model.x , model.y - YSTART - SIZE)
            bitmap.draw(gun, matrix);
        }

        public function draw(deltaTime:Number, actor:Actor, bitmap:BitmapData):void {
            var model:SimplePlayerModel = SimplePlayerModel(actor.model)

            drawLow(deltaTime, model, bitmap);
            drawMedium(deltaTime, model, bitmap);
        }
    }
}