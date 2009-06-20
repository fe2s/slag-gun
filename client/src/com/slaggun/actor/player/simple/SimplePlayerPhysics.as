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
import com.slaggun.actor.world.InputState;
import com.slaggun.actor.world.PhysicalWorld;

import flash.ui.Keyboard;

    /**
     * This is physical calculator for the SimplePlayer
     *
     * Author Dmitry Brazhnik (amid.ukr@gmail.com)
     *
     * @see SimplePlayer 
     */
    public class SimplePlayerPhysics implements ActorPhysics{

        public function live(deltaTime:Number,actor:Actor, world:PhysicalWorld):void {
            var x:Number = 0;
            var y:Number = 0;

            var myActor:SimplePlayer = SimplePlayer(actor);

            var inputState:InputState = world.inputStates;

            // procces key events
            if(inputState.isPressed(Keyboard.LEFT)){
                x -= 1;
            }

            if(inputState.isPressed(Keyboard.RIGHT)){
                x += 1;
            }

            if(inputState.isPressed(Keyboard.UP)){
                y -= 1;
            }

            if(inputState.isPressed(Keyboard.DOWN)){
                y += 1;
            }

            // update actor model
            var actorModel:SimplePlayerModel = SimplePlayerModel(myActor.model);
            actorModel.vx = x * deltaTime
            actorModel.vy = y * deltaTime

            actorModel.x += actorModel.vx * 0.02;
            actorModel.y += actorModel.vy * 0.02;

            actorModel.lookX = world.inputStates.mousePosition.x - actorModel.x
            actorModel.lookY = world.inputStates.mousePosition.y - actorModel.y
        }
    }
}