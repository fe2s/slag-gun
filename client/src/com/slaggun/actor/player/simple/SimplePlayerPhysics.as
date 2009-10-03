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
import com.slaggun.GameEnvironment;
import com.slaggun.InputState;
import com.slaggun.actor.base.Actor;
import com.slaggun.actor.base.ActorPhysics;
import com.slaggun.actor.player.PlayerConstants;
import com.slaggun.actor.shell.pistol.PistolShellFactory;
import com.slaggun.geom.Point2d;
import com.slaggun.geom.Vector2d;
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

    private var log:Logger = Logger.getLogger();

    public function liveServer(timePass:Number, actor:Actor, world:GameEnvironment):void {
        
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

        live(timePass, actor, world);

        actorModel.look.x = world.inputStates.mousePosition.x - actorModel.position.x;
        actorModel.look.y = world.inputStates.mousePosition.y - actorModel.position.y;
    }

    public function liveClient(timePass:Number, actor:Actor, world:GameEnvironment):void {

        var actorModel:SimplePlayerModel = SimplePlayerModel(actor.model);

        var vx:Number = actorModel.velocity.x;
        var vy:Number = actorModel.velocity.y;

        var x:Number = actorModel.position.x;
        var y:Number = actorModel.position.y;


        actorModel.velocity.x = vx;
        actorModel.velocity.y = vy;

        actorModel.position.x = x + vx * timePass;
        actorModel.position.y = y + vy * timePass;
    }

    protected function live(timePass:Number, actor:Actor, world:GameEnvironment){

    }

    private function shoot(actorModel:SimplePlayerModel, world:GameEnvironment):void {
        const mineActor:Boolean = false;
        const replicatedOnce:Boolean = true;

        var shellPosition:Point2d = Point2d.valueOf(actorModel.position);
        var shellDirection:Vector2d = new Vector2d(actorModel.look.x, actorModel.look.y);

        // to not kill yourself =)
        shellDirection.normalize(PlayerConstants.RADIUS + 1);
        shellPosition.translate(shellDirection);

        var shellFactory:PistolShellFactory = new PistolShellFactory();
        var shell:Actor = shellFactory.create(shellPosition, shellDirection);

        world.add(shell, mineActor, replicatedOnce);
    }
}
}