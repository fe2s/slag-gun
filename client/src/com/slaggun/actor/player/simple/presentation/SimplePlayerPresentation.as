/* Copyright 2011 SlagGunTeam
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
 * Unless required by applicable law or agreed to in writing, software distributed under the
 * License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND,
 * either express or implied. See the License for the specific language governing permissions
 * and limitations under the License.
 */
package com.slaggun.actor.player.simple.presentation {
import com.slaggun.actor.common.DrawOption;
import com.slaggun.actor.player.simple.SimplePlayerModel;
import com.slaggun.actor.player.simple.presentation.BasePlayerPresentation;

import flash.display.BitmapData;

import flash.display.DisplayObject;
import flash.geom.Matrix;

/**
 * @author Dmitry Brazhnik (amid.ukr@gmail.com)
 */
public class SimplePlayerPresentation extends BasePlayerPresentation{
    [Embed(source="stalker.png")]
    public static var stalkerResourceClass:Class;
    public static var stalkerResource:DisplayObject = new stalkerResourceClass();

    public function SimplePlayerPresentation() {
        super(stalkerResource, 1/15);
    }

    private function getAngle(x:Number, y:Number):Number {

        var angle:Number = Math.atan(((1.0) * y) / x);
        angle = x >= 0 ? angle : angle + Math.PI;
        angle += 2 * Math.PI;
        angle %= 2 * Math.PI;
        return angle;
    }

    protected override function drawFrame(target:SimplePlayerModel, bitmap:BitmapData, x:int, y:int, xFrame:Number, yFrame:Number):void{

        var vx:Number = target.velocity.x;
        var vy:Number = target.velocity.y;

        var lx:Number = target.look.x - target.position.x;
        var ly:Number = target.look.y - target.position.y;

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

        draw(bitmap, x, y, revesrs ? xFramesCount - xFrame : xFrame, 0, DrawOption.create().setMatrix(veloMat));
        draw(bitmap, x, y, 0,                                                 1, DrawOption.create().setMatrix(lookMat));
    }
}
}
