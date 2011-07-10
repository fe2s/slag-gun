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
import com.slaggun.util.Utils;

import flash.display.BitmapData;
import flash.display.DisplayObject;
import flash.geom.Matrix;
import flash.geom.Point;

/**
 * @author Dmitry Brazhnik (amid.ukr@gmail.com)
 */
public class SimplePlayerPresentation extends BasePlayerPresentation{
    [Embed(source="stalker.png")]
    public static var stalkerResourceClass:Class;
    public static var stalkerResource:DisplayObject = new stalkerResourceClass();

    private const MOUNT_POINT:Point = new Point(-1, 15);

    private var _mountPoint:Point;
    private var _weaponDirection:Point;

    public function SimplePlayerPresentation() {
        super(stalkerResource, 1/15);
    }

    public override function get maxSpeed():Number {
        return 0.3;
    }


    public override function get hitRadius():Number {
        return 20;
    }

    override public function weaponDirection(target:SimplePlayerModel):Point {
        return _weaponDirection;
    }

    override public function weaponMountPoint(target:SimplePlayerModel):Point {
        return _mountPoint;

    }

    protected function lookDirection(a:Number, position:Point, look:Point):Point{
        var pv:Point = look.subtract(position);
        var p:Number = pv.length;

        if(a >= p){
            p = a + 1;
            pv.normalize(p);
        }

        var b:Number = Math.sqrt(p*p - a*a);

        var pt:Number = a / b * p;
        var ptv:Point = new Point(-pv.y, pv.x);
        ptv.normalize(pt);

        var bv:Point = pv.subtract(ptv);
        bv.normalize(1);
        return bv;
    }

    protected override function drawFrame(target:SimplePlayerModel, bitmap:BitmapData, x:int, y:int, xFrame:Number, yFrame:Number):void{

        var vx:Number = target.velocity.x;
        var vy:Number = target.velocity.y;

        var lookDirection:Point = this.lookDirection(MOUNT_POINT.y, target.position, target.look);
        var lx:Number = lookDirection.x;
        var ly:Number = lookDirection.y;

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

        var lookMat:Matrix =  Utils.roateMatrix(lx, ly);
        var veloMat:Matrix =  Utils.roateMatrix(vx, vy);

        draw(bitmap, x, y, revesrs ? xFramesCount - xFrame : xFrame, 0, DrawOption.create().setMatrix(veloMat));
        draw(bitmap, x, y, 0,                                        1, DrawOption.create().setMatrix(lookMat));

        _mountPoint = lookMat.transformPoint(MOUNT_POINT);
        _weaponDirection = lookDirection;
    }
}
}
