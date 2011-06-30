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

package com.slaggun.actor.player.simple.presentation {
import com.slaggun.actor.common.ImageFramedResource;
import com.slaggun.actor.player.simple.PlayerPresentation;
import com.slaggun.actor.player.simple.SimplePlayerModel;
import com.slaggun.util.NotImplementedException;

import flash.display.BitmapData;
import flash.display.DisplayObject;
import flash.geom.Point;

/**
 * @author Dmitry Brazhnik (amid.ukr@gmail.com)
 */
public class BasePlayerPresentation extends ImageFramedResource implements PlayerPresentation{
    /**
     * Previous time step.
      */
    private var xTime:Number = 0;

    private var _frameSpeedFactor:Number;

    public function BasePlayerPresentation(image:DisplayObject, frameSpeedFactor:Number) {
        super(image);
        _frameSpeedFactor = frameSpeedFactor;
    }

    //--------------------------------------------------------
    //-----------------  ACTOR DECLARATION -------------------
    //--------------------------------------------------------


    public function get maxSpeed():Number {
        throw NotImplementedException.create(this, "maxSpeed");
    }


    public function get hitRadius():Number {
        throw NotImplementedException.create(this, "hitRadius");
    }

    public function weaponMountPoint(target:SimplePlayerModel):Point{
        throw NotImplementedException.create(this, "weaponMountPoint");
    }

    public function weaponDirection(target:SimplePlayerModel):Point {
        throw NotImplementedException.create(this, "weaponDirection");
    }

    public function bulletStartPoint(target:SimplePlayerModel):Point {
        throw NotImplementedException.create(this, "bulletStartPoint");
    }

//--------------------------------------------------------
    //---------------------  RENDER API -----------------------
    //--------------------------------------------------------

    /**
     * Returns ImageFramedResource frame width. Assumed that resource frame is square, so it returns getFrameHeight().
     * @return com.slaggun.actor.common.ImageFramedResource frame width.
     */
    override protected function getFrameWidth():int {
        return super.getFrameHeight();
    }

    /**
     * Returns 8;
     * @return 8
     */
    override protected function getYFramesCount():int {
        return 8;
    }

    protected function getRow(deltaTime:Number, actor:SimplePlayerModel):int{
        return 0;
    }

    private function getTimeFrame(deltaTime:Number, target:SimplePlayerModel):int{

        var vx:Number = target.velocity.x;
        var vy:Number = target.velocity.y;

        var xFrame:int;

        var v:Number = target.velocity.length;

        if (vx == 0 && vy == 0) {
            xFrame = 0;
            xTime = 0;
        } else {
            xTime += (v * deltaTime) * _frameSpeedFactor;
            xTime = xTime % (xFramesCount - 1);
            xFrame = xTime + 1;
        }

         return xFrame;
    }

    protected function drawFrame(target:SimplePlayerModel, bitmap:BitmapData, x:int, y:int, xFrame:Number, yFrame:Number):void{
        draw(bitmap, x, y, xFrame, yFrame);
    }

    public function render(deltaTime:Number, target:SimplePlayerModel, bitmap:BitmapData):void {


        var x:Number = target.position.x;
        var y:Number = target.position.y;

        drawFrame(target, bitmap, x, y, getTimeFrame(deltaTime, target),
                                              getRow(deltaTime, target));
     }
}
}
