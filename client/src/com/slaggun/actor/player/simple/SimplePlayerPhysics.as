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
import com.slaggun.InputState;
import com.slaggun.actor.base.Actor;
import com.slaggun.actor.base.ActorPhysics;
import com.slaggun.actor.player.PlayerConstants;
import com.slaggun.actor.shell.pistol.PistolShellFactory;
import com.slaggun.util.log.Logger;

import flash.geom.Point;
import flash.ui.Keyboard;

/**
 * This is physical calculator for the SimplePlayer
 *
 * Author Dmitry Brazhnik (amid.ukr@gmail.com)
 *
 * @see SimplePlayer
 */
public class SimplePlayerPhysics implements ActorPhysics{

    private var log:Logger = Logger.getLogger(SimplePlayerPhysics);
    private var serverModel:SimplePlayerModel;

    public function liveServer(timePass:Number, actor:Actor, world:Game):void {
        
        var actorModel:SimplePlayerModel = SimplePlayerModel(actor.model);

        var vx:Number = 0;
        var vy:Number = 0;

        var inputState:InputState = world.inputStates;

        // procces key events
        if (inputState.isPressed(Keyboard.LEFT)) {
            vx -= 1;
        }

        if (inputState.isPressed(Keyboard.RIGHT)) {
            vx += 1;
        }

        if (inputState.isPressed(Keyboard.UP)) {
            vy -= 1;
        }

        if (inputState.isPressed(Keyboard.DOWN)) {
            vy += 1;
        }

        if (inputState.isMousePressed()) {
            shoot(actorModel, world);
        }

        // update actor model


        var v:Number = Math.sqrt(vx * vx + vy * vy) / PlayerConstants.PLAYER_SPEED_PER_MS;

        if (v != 0) {
            vx /= v;
            vy /= v;
        }

        actorModel.velocity.x = vx;
        actorModel.velocity.y = vy;

        live(timePass, actorModel);

        actorModel.look.x = world.inputStates.mousePosition.x - actorModel.position.x;
        actorModel.look.y = world.inputStates.mousePosition.y - actorModel.position.y;
    }

    public function liveClient(timePass:Number, actor:Actor, world:Game):void {

        var actorModel:SimplePlayerModel = SimplePlayerModel(actor.model);

        live(timePass, serverModel);

        var actorX:Number = actorModel.position.x;
        var actorY:Number = actorModel.position.y;

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
                actorModel.velocity.x = v*vx/timePass;
                actorModel.velocity.y = v*vy/timePass;
            }else{
                actorModel.velocity.x = serverModel.velocity.x;
                actorModel.velocity.y = serverModel.velocity.y;
            }


            actorModel.position.x = actorX;
            actorModel.position.y = actorY;
        }
    }

    protected function live(timePass:Number, actorModel:SimplePlayerModel):void{
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

    public function receiveSnapshot(object:Object, actor:Actor, world:Game):void {

        var receivedModel:SimplePlayerModel = SimplePlayerModel(object);

        var currentPosition:Point;

        var actorModel:SimplePlayerModel = SimplePlayerModel(actor.model);

        if(serverModel == null){
            currentPosition = receivedModel.position.clone();
        }else{
            currentPosition = actorModel.position;
        }

        serverModel = SimplePlayerModel(object);

        actorModel = serverModel.clone();
        actorModel.position = currentPosition;

        actor.model = actorModel; 
    }


    private function shoot(actorModel:SimplePlayerModel, world:Game):void {
        const mineActor:Boolean = false;
        const replicatedOnce:Boolean = true;

        var shellPosition:Point = actorModel.position.clone();
        var shellDirection:Point = new Point(actorModel.look.x, actorModel.look.y);

        // to not kill yourself =)
        shellDirection.normalize(PlayerConstants.RADIUS + 1);
        shellPosition.offset(shellDirection.x, shellDirection.y);

        var shellFactory:PistolShellFactory = new PistolShellFactory();
        var shell:Actor = shellFactory.create(shellPosition, shellDirection);

        world.gameActors.add(shell, mineActor, replicatedOnce);
    }
}
}