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
import com.slaggun.actor.base.AbstractActor;
import com.slaggun.actor.base.Action;
import com.slaggun.actor.base.Actor;

/**
 *
 * @author Oleksiy Dyagilev (aka.fe2s@gmail.com)
 */
public class PistolShell extends AbstractActor implements Actor{

    public function PistolShell() {
        _model = new PistolShellModel();
        _renderer = new PistolShellRenderer();
    }

    override public function apply(action:Action):void {
        action.applyToPistolShell(this);
    }

    override public function live(timePass:Number, world:Game):void {
        var shellModel:PistolShellModel = PistolShellModel(model);
        translateShell(shellModel);
        hit(world);

        var x:Number = shellModel.position.x;
        var y:Number = shellModel.position.y;

        if(x<0 || y<0 || x > world.mapWidth || y > world.mapHeight){
            world.gameActors.remove(this);
        }
    }

    private function translateShell(shell:PistolShellModel):void {
        shell.position.offset(shell.speedVector.x, shell.speedVector.y);
    }

    private function hit(world:Game):void{
        var hitAction:PistolShellHitAction = new PistolShellHitAction(this, world);
        var len:int = world.gameActors.actors.length;
        var actors:Array = world.gameActors.actors;
        for(var i:int = 0; i < len; i++){
            var actor:Actor = actors[i];
            actor.apply(hitAction);
        }
    }
}
}