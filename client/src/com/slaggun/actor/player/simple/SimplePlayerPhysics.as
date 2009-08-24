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
import com.slaggun.actor.base.Actor;
import com.slaggun.actor.base.ActorPhysics;
import com.slaggun.actor.player.PlayerConstants;
import com.slaggun.actor.shell.pistol.PistolShellFactory;
import com.slaggun.actor.world.InputState;
import com.slaggun.actor.world.PhysicalWorld;

import com.slaggun.geom.Point2d;

import com.slaggun.geom.Vector2d;

import com.slaggun.util.log.Logger;

import flash.ui.Keyboard;
import flash.ui.Mouse;

/**
 * This is physical calculator for the SimplePlayer
 *
 * Author Dmitry Brazhnik (amid.ukr@gmail.com)
 *
 * @see SimplePlayer
 */
public class SimplePlayerPhysics implements ActorPhysics{

    private var log:Logger = Logger.getLogger();

    public function live(timePass:Number, actor:Actor, world:PhysicalWorld):void {

        if (!world.isMineActor(actor)) {
            return;
        }

        var actorModel:SimplePlayerModel = SimplePlayerModel(actor.model);

        var clickX:Number = 0;
        var clickY:Number = 0;

        var vx:Number = 0;
        var vy:Number = 0;

        var x:Number = actorModel.position.x;
        var y:Number = actorModel.position.y;

        var mouseX:Number = world.inputStates.mousePosition.x;
        var mouseY:Number = world.inputStates.mousePosition.y;

        var inputState:InputState = world.inputStates;

        // procces key events
        if (inputState.isPressed(Keyboard.LEFT)) {
            clickX -= 1;
        }

        if (inputState.isPressed(Keyboard.RIGHT)) {
            clickX += 1;
        }

        if (inputState.isPressed(Keyboard.UP)) {
            clickY -= 1;
        }

        if (inputState.isPressed(Keyboard.DOWN)) {
            clickY += 1;
        }

        if (inputState.isMousePressed()) {
            shoot(actorModel, world);
        }

        // update actor model

        vx = clickX;
        vy = clickY;

        var v:Number = Math.sqrt(vx*vx+vy*vy)/PlayerConstants.PLAYER_SPEED_PER_MS;

        if(v != 0){
            vx/= v;
            vy/= v;
        }

        actorModel.velocity.x = vx;
        actorModel.velocity.y = vy;

        actorModel.position.x = x + vx * timePass;
        actorModel.position.y = y + vy * timePass;

        actorModel.look.x = mouseX - x;
        actorModel.look.y = mouseY - y;
    }

    private function shoot(actorModel:SimplePlayerModel, world:PhysicalWorld):void {
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