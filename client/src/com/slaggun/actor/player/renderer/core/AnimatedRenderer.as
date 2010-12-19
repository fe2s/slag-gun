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
import com.slaggun.actor.base.ActorRenderer;

import com.slaggun.actor.player.simple.SimplePlayerModel;

import flash.display.BitmapData;

/**
 * @author Dmitry Brazhnik (amid.ukr@gmail.com)
 */
public class AnimatedRenderer implements ActorRenderer{

    private var _resource:DirectedResource;
    private var _frameSpeedFactor:Number;

    /**
     * Previous time step.
      */
    private var xTime:Number = 0;

    public function AnimatedRenderer(resource:DirectedResource, frameSpeedFactor:Number) {
        this._resource = resource;
        _frameSpeedFactor = frameSpeedFactor;
    }

    protected function get resource():DirectedResource{
        return _resource;
    }

    protected function getRow(deltaTime:Number, actor:Actor):int{
        return 0;
    }

    private function getTimeFrame(deltaTime:Number, actor:Actor):int{
        var model:SimplePlayerModel = SimplePlayerModel(actor.model);

        var vx:Number = model.velocity.x;
        var vy:Number = model.velocity.y;

        var xFrame:int;

        var v:Number = model.velocity.length;

        if (vx == 0 && vy == 0) {
            xFrame = 0;
            xTime = 0;
        } else {
            xTime += (v * deltaTime) * _frameSpeedFactor;
            xTime = xTime % (resource.xFramesCount - 1);
            xFrame = xTime + 1;
        }

         return xFrame;
    }

    protected function drawFrame(actor:Actor, bitmap:BitmapData, x:int, y:int, xFrame:Number, yFrame:Number):void{
        resource.draw(bitmap, x, y, xFrame, yFrame);
    }

    public function draw(deltaTime:Number, actor:Actor, bitmap:BitmapData):void {
        var model:SimplePlayerModel = SimplePlayerModel(actor.model);

        var x:Number = model.position.x;
        var y:Number = model.position.y;

        drawFrame(actor, bitmap, x, y, getTimeFrame(deltaTime, actor),
                                             getRow(deltaTime, actor));
     }
}
}