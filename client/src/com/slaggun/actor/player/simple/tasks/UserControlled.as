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
import com.slaggun.InputState;
import com.slaggun.actor.base.Actor;
import com.slaggun.actor.base.ActorTask;
import com.slaggun.actor.player.simple.SimplePlayerModel;
import com.slaggun.actor.player.simple.SimplePlayerPhysics;

import flash.ui.Keyboard;

/**
 * @author Dmitry Brazhnik (amid.ukr@gmail.com)
 */
public class UserControlled implements ActorTask{

    public function controlActor(actor:Actor, deltaTime:Number, game:Game):void {
        var vx:Number = 0;
        var vy:Number = 0;

        var inputState:InputState = game.inputStates;


        // procces key events
        if (inputState.isPressed(Keyboard.LEFT) || inputState.isPressedChar('A')) {
            vx -= 1;
        }

        if (inputState.isPressed(Keyboard.RIGHT) || inputState.isPressedChar('D')) {
            vx += 1;
        }

        if (inputState.isPressed(Keyboard.UP) || inputState.isPressedChar('W')) {
            vy -= 1;
        }

        if (inputState.isPressed(Keyboard.DOWN) || inputState.isPressedChar('S')) {
            vy += 1;
        }

        var physics:SimplePlayerPhysics = SimplePlayerPhysics(actor.physics);

        if (inputState.isMousePressed()) {
            physics.shoot(SimplePlayerModel(actor.model), game);
        }

        physics.moveDirection(vx, vy, deltaTime, actor, game);
        physics.lookAt(inputState.mousePosition.x, inputState.mousePosition.y, deltaTime, actor, game);
    }
}
}
