/*
 * Copyright 2011 SlagGunTeam
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
 * Unless required by applicable law or agreed to in writing, software distributed under the
 * License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND,
 * either express or implied. See the License for the specific language governing permissions
 * and limitations under the License.
 */

package com.slaggun.actor.player.simple.tasks {
import com.slaggun.Game;
import com.slaggun.actor.base.Actor;
import com.slaggun.actor.base.ActorTask;
import com.slaggun.actor.base.BaseActorTask;
import com.slaggun.actor.player.PlayerConstants;
import com.slaggun.actor.player.simple.SimplePlayer;
import com.slaggun.actor.player.simple.SimplePlayerModel;

/**
 * @author Dmitry Brazhnik (amid.ukr@gmail.com)
 */
public class Bot extends BaseActorTask{
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


    override public function controlActor(_actor:Actor, deltaTime:Number, game:Game):void {
        var actorModel:SimplePlayerModel = SimplePlayerModel(_actor.model);
        var actor:SimplePlayer = SimplePlayer(_actor);

        timePass+=deltaTime;

        var vx:Number = actorModel.velocity.x;
        var vy:Number = actorModel.velocity.y;

        var x:Number = actorModel.position.x;
        var y:Number = actorModel.position.y;



        if(timePass > 1000){
            timePass-=1000;

            vx = randV() * actor.maxSpeed;
            vy = randV() * actor.maxSpeed;

            actor.lookAt(Math.random()*game.mapWidth, Math.random()*game.mapHeight, deltaTime, game);
        }

        if(x <0 )                    vx =  Math.abs(actorModel.velocity.x);
        else if(x > game.mapWidth)  vx = -Math.abs(actorModel.velocity.x);

        if(y <0 )                    vy =  Math.abs(actorModel.velocity.y);
        else if(y > game.mapHeight) vy = -Math.abs(actorModel.velocity.y);


        actor.moveDirection(vx, vy, deltaTime, game);
    }
}
}
