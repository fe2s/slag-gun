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
import com.slaggun.actor.player.simple.SimplePlayer;

import flash.ui.Keyboard;

/**
 * @author Dmitry Brazhnik (amid.ukr@gmail.com)
 */
public class UserControlled implements ActorTask{

    public function controlActor(_actor:Actor, deltaTime:Number, game:Game):void {
        var vx:Number = 0;
        var vy:Number = 0;

        var inputState:InputState = game.inputStates;
        var actor:SimplePlayer = SimplePlayer(_actor);


        // procces key events
        if (inputState.isPressed(Keyboard.LEFT) || inputState.isPressedChar('A')) {
            vx -= actor.maxSpeed;
        }

        if (inputState.isPressed(Keyboard.RIGHT) || inputState.isPressedChar('D')) {
            vx += actor.maxSpeed;
        }

        if (inputState.isPressed(Keyboard.UP) || inputState.isPressedChar('W')) {
            vy -= actor.maxSpeed;
        }

        if (inputState.isPressed(Keyboard.DOWN) || inputState.isPressedChar('S')) {
            vy += actor.maxSpeed;
        }

        if (inputState.isMousePressed()) {
            actor.shoot(game);
        }

        actor.moveDirection(vx, vy, deltaTime, game);
        actor.lookAt(inputState.mousePosition.x, inputState.mousePosition.y, deltaTime, game);
    }
}
}
