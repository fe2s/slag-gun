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
import com.slaggun.Game;
import com.slaggun.actor.base.Actor;
import com.slaggun.actor.base.BaseActorPhysics;

/**
 *
 * @author Oleksiy Dyagilev (aka.fe2s@gmail.com)
 */
public class PistolShellPhysics extends BaseActorPhysics {

    public override function liveClient(deltaTime:Number, actor:Actor, world:Game):void {
        var shell:PistolShell = PistolShell(actor);
        var shellModel:PistolShellModel = PistolShellModel(actor.model);
        translateShell(shellModel);
        hit(shell, world);

        var x:Number = shellModel.position.x;
        var y:Number = shellModel.position.y;

        if(x<0 || y<0 || x > world.mapWidth || y > world.mapHeight){
            world.gameActors.remove(actor);
        }
    }

    private function translateShell(shell:PistolShellModel):void {
        shell.position.offset(shell.speedVector.x, shell.speedVector.y);
    }

    private function hit(shell:PistolShell, world:Game):void{
        var hitAction:PistolShellHitAction = new PistolShellHitAction(shell, world);
        var len:int = world.gameActors.actors.length;
        var actors:Array = world.gameActors.actors;
        for(var i:int = 0; i < len; i++){
            var actor:Actor = actors[i];
            actor.apply(hitAction);
        }
    }
}
}