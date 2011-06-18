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

package com.slaggun.actor.player.simple {
import com.slaggun.Game;
import com.slaggun.actor.base.AbstractActor;
import com.slaggun.actor.base.Action;
import com.slaggun.actor.base.Actor;
import com.slaggun.actor.player.PlayerConstants;
import com.slaggun.actor.player.renderer.StalkerPlayerResource;
import com.slaggun.actor.shell.pistol.PistolShellFactory;
import com.slaggun.events.SimpleActorSnapshot;
import com.slaggun.events.UpdateActorSnapshot;

import flash.geom.Point;

/**
 * This is the first implementation of user controlled game character
 *
 * Author Dmitry Brazhnik (amid.ukr@gmail.com)
 *
 * @see Actor
 */
public class SimplePlayer extends AbstractActor implements Actor {

    private var serverModel:SimplePlayerModel;

    public function SimplePlayer() {
        _renderer = StalkerPlayerResource.createRenderer();
        _model = new SimplePlayerModel();
    }

    override public function apply(action:Action):void {
        action.applyToSimplePlayer(this);
    }

    /**
     * Hit player (decrease health)
     * @param hitPoints
     * @return true if still live, false if person has died  :)
     */
    public function hit(hitPoints:int):Boolean {
        return SimplePlayerModel(_model).hit(hitPoints);
    }

    /**
     * Respawn player
     */
    public function respawn():void{
        SimplePlayerModel(_model).respawn();
    }

    //--------------------------------------------------------
    //---------------------  ACTOR API -----------------------
    //--------------------------------------------------------

    public function lookAt(x:int, y:int, timePass:Number, world:Game):void {
        var actorModel:SimplePlayerModel = SimplePlayerModel(model);

        actorModel.look.x = x - actorModel.position.x;
        actorModel.look.y = y - actorModel.position.y;
    }

    public function moveDirection(vx:Number, vy:Number, timePass:Number, world:Game):void {
        var v:Number = Math.sqrt(vx * vx + vy * vy) / PlayerConstants.PLAYER_SPEED_PER_MS;

        if(v != 0){
            vx /= v;
            vy /= v;
        }

        velocity(vx, vy, timePass, world);
    }

    public function velocity(vx:Number, vy:Number, timePass:Number, world:Game):void {
        var v:Number = Math.sqrt(vx * vx + vy * vy);

        if(v > PlayerConstants.PLAYER_SPEED_PER_MS){
            v /= PlayerConstants.PLAYER_SPEED_PER_MS;
            vx /= v;
            vy /= v;
        }

        var actorModel:SimplePlayerModel = SimplePlayerModel(model);

        actorModel.velocity.x = vx;
        actorModel.velocity.y = vy;
    }

    //--------------------------------------------------------
    //----------------  ACTOR GAME METHODS -------------------
    //--------------------------------------------------------

    override public function live(timePass:Number, world:Game):void {
        if(replicable){
            world.gameActors.replicate(this);
        }

        var actorModel:SimplePlayerModel = SimplePlayerModel(model);
        if(mine){
            iterateModel(timePass, actorModel);
        }else{
            iterateModel(timePass, serverModel);
            clientSpringMove(timePass, serverModel, actorModel);
        }
    }

    protected function clientSpringMove(timePass:Number, serverModel:SimplePlayerModel, clientModel:SimplePlayerModel):void{
        var actorX:Number = clientModel.position.x;
        var actorY:Number = clientModel.position.y;

        var serverActorX:Number = serverModel.position.x;
        var serverActorY:Number = serverModel.position.y;

        var vx:Number = (serverActorX - actorX);
        var vy:Number = (serverActorY - actorY);
        var distance:Number = Math.sqrt(vx*vx + vy*vy);
        if(distance != 0){
            vx/=distance;
            vy/=distance;

            var v:Number = distance/10;
            var minSpeed:Number = timePass*PlayerConstants.PLAYER_SPEED_PER_MS;

            if(v < minSpeed){
                v = minSpeed;
            }

            if(v > distance){
                v = distance;
            }

            actorX = vx*v + actorX;
            actorY = vy*v + actorY;

            if(v > timePass * PlayerConstants.PLAYER_SPEED_PER_MS/2){
                clientModel.velocity.x = v*vx/timePass;
                clientModel.velocity.y = v*vy/timePass;
            }else{
                clientModel.velocity.x = serverModel.velocity.x;
                clientModel.velocity.y = serverModel.velocity.y;
            }


            clientModel.position.x = actorX;
            clientModel.position.y = actorY;
        }
    }

    protected function iterateModel(timePass:Number, actorModel:SimplePlayerModel):void{
        var vx:Number = actorModel.velocity.x;
        var vy:Number = actorModel.velocity.y;

        var x:Number = actorModel.position.x;
        var y:Number = actorModel.position.y;


        actorModel.velocity.x = vx;
        actorModel.velocity.y = vy;

        actorModel.position.x = x + vx * timePass;
        actorModel.position.y = y + vy * timePass;
    }

    public function createSnapshot(actor:Actor, world:Game):Object {
        return actor.model;
    }


    override public function retrieveUpdateSnapshot(game:Game, snapshot:UpdateActorSnapshot):void {
        var receivedModel:SimplePlayerModel = SimplePlayerModel(SimpleActorSnapshot(snapshot).model);

        var currentPosition:Point;

        var actorModel:SimplePlayerModel = SimplePlayerModel(model);

        if(serverModel == null){
            currentPosition = receivedModel.position.clone();
        }else{
            currentPosition = actorModel.position;
        }

        serverModel = receivedModel;

        actorModel = serverModel.clone();
        actorModel.position = currentPosition;

        model = actorModel;
    }


    public function shoot(world:Game):void {
        var actorModel:SimplePlayerModel = SimplePlayerModel(model);

        const mineActor:Boolean = false;
        const replicatedOnce:Boolean = true;

        var shellPosition:Point = actorModel.position.clone();
        var shellDirection:Point = new Point(actorModel.look.x, actorModel.look.y);

        // to not kill yourself =)
        shellDirection.normalize(PlayerConstants.RADIUS + 1);
        shellPosition.offset(shellDirection.x, shellDirection.y);

        var shellFactory:PistolShellFactory = new PistolShellFactory();
        var shell:Actor = shellFactory.create(shellPosition, shellDirection);

        world.gameActors.add(shell);
    }
}
}