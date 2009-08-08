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

        private static function randV():Number{
            var number:Number = Math.random();
                if(number < 0.33){
                    return -1;
                }else if (number > 0.66){
                    return 1;
                }else{
                    return 0;
                }
        }

        public function BotPhysics() {
        }

        public function live(deltaTime:Number, actor:Actor, world:PhysicalWorld):void {
            var actorModel:SimplePlayerModel = SimplePlayerModel(actor.model);

            timePass+=deltaTime;

            var vx:Number = actorModel.velocity.x;
            var vy:Number = actorModel.velocity.y;

            var x:Number = actorModel.position.x;
            var y:Number = actorModel.position.y;

            if(x <0 || x > world.width){

                if(actorModel.position.x <0){
                    x = 0;
                }else{
                    x = world.width - 1;
                }

                vx = - actorModel.velocity.x;
            }

            if(y <0 || y > world.height){

                if(y <0){
                    y = 0;
                }else{
                    y = world.height - 1;
                }

                vy = - actorModel.velocity.y;
            }

            if(timePass > 100){
                timePass-=100;

                vx = randV() * PlayerConstants.PLAYER_SPEED_PER_MS;
                vy = randV() * PlayerConstants.PLAYER_SPEED_PER_MS;

                var rect:Rectangle = world.bitmap.rect;

                actorModel.look.x = Math.random()*world.width;
                actorModel.look.y = Math.random()*world.height;
            }

            x += vx*deltaTime;
            y += vy*deltaTime;

            actorModel.velocity.x = vx;
            actorModel.velocity.y = vy;

            actorModel.position.x = x;
            actorModel.position.y = y;
        }
    }
}