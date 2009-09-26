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

package com.slaggun.actor.shell.pistol {
import com.slaggun.actor.base.Actor;
import com.slaggun.actor.base.ActorPhysics;
import com.slaggun.GameEnvironment;

/**
 *
 * @author Oleksiy Dyagilev (aka.fe2s@gmail.com)
 */
public class PistolShellPhysics implements ActorPhysics {

    public function live(deltaTime:Number, actor:Actor, world:GameEnvironment):void {
        var shell:PistolShell = PistolShell(actor);
        var shellModel:PistolShellModel = PistolShellModel(actor.model);
        translateShell(shellModel);
        hit(shell, world);

        // TODO: if is out of the world, destruct it
    }

    private function translateShell(shell:PistolShellModel):void {
        shell.position.translate(shell.speedVector);
    }

    private function hit(shell:PistolShell, world:GameEnvironment):void{
        var hitAction:PistolShellHitAction = new PistolShellHitAction(shell, world);
        for each (var actor:Actor in world.actors){
            actor.apply(hitAction);
        }
    }
}
}