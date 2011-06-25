/*
 * Copyright 2010 SlagGunTeam
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
 * Unless required by applicable law or agreed to in writing, software distributed under the
 * License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND,
 * either express or implied. See the License for the specific language governing permissions
 * and limitations under the License.
 */

package com.slaggun.actor.player.renderer.core {
import com.slaggun.actor.base.Actor;
import com.slaggun.actor.player.simple.SimplePlayerModel;

import flash.display.BitmapData;
import flash.geom.Matrix;

/**
 * @author Dmitry Brazhnik (amid.ukr@gmail.com)
 */
public class SimplePlayerRenderer extends AnimatedRenderer{
    
    public function SimplePlayerRenderer(resource:DirectedResource, frameSpeedFactor:Number) {
        super(resource, frameSpeedFactor);
    }

    private function getAngle(x:Number, y:Number):Number {

        var angle:Number = Math.atan(((1.0) * y) / x);
        angle = x >= 0 ? angle : angle + Math.PI;
        angle += 2 * Math.PI;
        angle %= 2 * Math.PI;
        return angle;
    }

    protected override function drawFrame(actor:Actor, bitmap:BitmapData, x:int, y:int, xFrame:Number, yFrame:Number):void{

        var model:SimplePlayerModel = SimplePlayerModel(actor.model);

        var vx:Number = model.velocity.x;
        var vy:Number = model.velocity.y;

        var lx:Number = model.look.x;
        var ly:Number = model.look.y;

        if (vx == 0 && vy == 0) {
            vx = lx;
            vy = ly;
        }

        var revesrs:Boolean = false;

        if(vx*lx + vy*ly < 0){
            vx = -vx;
            vy = -vy;
            revesrs = true
        }

        var lookMat:Matrix =  new Matrix();
        lookMat.rotate(getAngle(lx, ly));

        var veloMat:Matrix =  new Matrix();
        veloMat.rotate(getAngle(vx, vy));
        
        resource.draw(bitmap, x, y, revesrs ? resource.xFramesCount - xFrame : xFrame, 0, DrawOption.create().setMatrix(veloMat));
        resource.draw(bitmap, x, y, 0,                                                 1, DrawOption.create().setMatrix(lookMat));
    }
}
}