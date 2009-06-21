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

package com.slaggun.actor.player.simple.bot {
import com.slaggun.actor.base.Actor;
import com.slaggun.actor.base.ActorPhysics;
import com.slaggun.actor.player.PlayerConstants;
import com.slaggun.actor.player.simple.SimplePlayerModel;
import com.slaggun.actor.world.PhysicalWorld;

import flash.geom.Rectangle;

public class BotPhysics implements ActorPhysics{

    private var timePass:Number = 1001;

    private function randV():Number{
        var number:Number = Math.random()
            if(number < 0.33){
                return -1;
            }else if (number > 0.66){
                return 1
            }else{
                return 0;
            }
    }

    public function live(deltaTime:Number, actor:Actor, world:PhysicalWorld):void {
        var actorModel:SimplePlayerModel = SimplePlayerModel(actor.model)

        timePass+=deltaTime

        var vx:Number = 0;
        var vy:Number = 0;

        if(timePass > 1000){
            timePass-=1000;
            actorModel.vx = randV() * PlayerConstants.PLAER_SPEED_PER_MS
            actorModel.vy = randV() * PlayerConstants.PLAER_SPEED_PER_MS

            var rect:Rectangle = world.bitmap.rect;

            actorModel.lookX = -(Math.random()*world.width - actorModel.x)
            actorModel.lookY = -(Math.random()*world.height - actorModel.y)
        }

        if(actorModel.x <0 || actorModel.x > world.width){

            if(actorModel.x <0){
                actorModel.x = 0;
            }else{
                actorModel.x = world.width - 1;
            }

            actorModel.vx = - actorModel.vx;
        }

        if(actorModel.y <0 || actorModel.y > world.height){

            if(actorModel.y <0){
                actorModel.y = 0;
            }else{
                actorModel.y = world.height - 1;
            }

            actorModel.vy = - actorModel.vy; 
        }

        actorModel.x += actorModel.vx * deltaTime
        actorModel.y += actorModel.vy * deltaTime
    }
}
}