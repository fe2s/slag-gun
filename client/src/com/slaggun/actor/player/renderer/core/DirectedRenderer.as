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

package com.slaggun.actor.player.renderer.core {
import com.slaggun.actor.base.Actor;
import com.slaggun.actor.base.ActorRenderer;
import com.slaggun.actor.player.simple.SimplePlayerModel;

import flash.display.BitmapData;

/**
 * This is renderer for the framed image file.
 * @see DirectedResource
 */
public class DirectedRenderer implements ActorRenderer{

    private var resource:DirectedResource;
    private var _frameSpeedFactor:Number;

    /**
     * Previous time step.
      */
    private var xTime:Number = 0;

    /**
     * Constructs DirectedRenderer with the specified png resource and frameSpeedFactor.
     *
     * @param resource - refence to x*8 png resource
     * @param frameSpeedFactor - is factor that used to synchronize actor velocity and animation timesteps 
     */
    public function DirectedRenderer(resource:DirectedResource, frameSpeedFactor:Number) {
        this.resource = resource;
        _frameSpeedFactor = frameSpeedFactor;
    }

    /**
     * Returns clockwise angle between positive x axis and specified (x, y) vector.
     * Thre returned is lied in   
     * @param x
     * @param y
     * @return
     */
    private function getAngle(x:Number, y:Number):Number {
        var angle:Number = Math.atan(((1.0) * y) / x);
        angle = x > 0 ? angle : angle + Math.PI;
        angle += 2 * Math.PI;
        angle %= 2 * Math.PI;
        return angle;
    }

    public function draw(deltaTime:Number, actor:Actor, bitmap:BitmapData):void {
        var model:SimplePlayerModel = SimplePlayerModel(actor.model);

        var x:Number = model.position.x;
        var y:Number = model.position.y;

        var lx:Number = model.look.x;
        var ly:Number = model.look.y;

        var vx:Number = model.velocity.x;
        var vy:Number = model.velocity.y;

        var xFrame:int;

        var v:Number = model.velocity.length;

        if (vx == 0 && vy == 0) {
            xFrame = 0;
            xTime = 0;
        } else {
            lx = vx;
            ly = vy;

            xTime += (v * deltaTime) * _frameSpeedFactor;
            xTime = xTime % (resource.xFramesCount - 1);
            xFrame = xTime + 1;
        }

        var lookAngle:Number = getAngle(lx, ly);

        lookAngle += Math.PI / 2;
        lookAngle %= 2 * Math.PI;

        var yFrame:int = resource.yFramesCount * lookAngle / (2 * Math.PI);

        resource.draw(bitmap, x, y, xFrame, yFrame);
    }




}
}