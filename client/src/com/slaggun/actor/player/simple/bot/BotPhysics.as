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
import com.slaggun.Game;
import com.slaggun.actor.base.Actor;
import com.slaggun.actor.player.PlayerConstants;
import com.slaggun.actor.player.simple.SimplePlayerModel;
import com.slaggun.actor.player.simple.SimplePlayerPhysics;

import flash.geom.Rectangle;

public class BotPhysics extends SimplePlayerPhysics{

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

        public override function liveServer(deltaTime:Number, actor:Actor, world:Game):void {
            var actorModel:SimplePlayerModel = SimplePlayerModel(actor.model);

            timePass+=deltaTime;

            var vx:Number = actorModel.velocity.x;
            var vy:Number = actorModel.velocity.y;

            var x:Number = actorModel.position.x;
            var y:Number = actorModel.position.y;



            if(timePass > 1000){
                timePass-=1000;

                vx = randV() * PlayerConstants.PLAYER_SPEED_PER_MS;
                vy = randV() * PlayerConstants.PLAYER_SPEED_PER_MS;

                var rect:Rectangle = world.gameRenderer.bitmap.rect;

                actorModel.look.x = Math.random()*world.mapWidth;
                actorModel.look.y = Math.random()*world.mapHeight;
            }

            if(x <0 )                    vx =  Math.abs(actorModel.velocity.x);
            else if(x > world.mapWidth)  vx = -Math.abs(actorModel.velocity.x);

            if(y <0 )                    vy =  Math.abs(actorModel.velocity.y);
            else if(y > world.mapHeight) vy = -Math.abs(actorModel.velocity.y);


            actorModel.velocity.x = vx;
            actorModel.velocity.y = vy;

            live(deltaTime, SimplePlayerModel(actor.model));
        }
    }
}