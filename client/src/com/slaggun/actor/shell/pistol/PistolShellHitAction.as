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
import com.slaggun.actor.base.Action;
import com.slaggun.actor.player.PlayerConstants;
import com.slaggun.actor.player.simple.SimplePlayer;
import com.slaggun.actor.player.simple.SimplePlayerModel;
import com.slaggun.GameEnvironment;
import com.slaggun.geom.Circle;
import com.slaggun.geom.Point2d;

import com.slaggun.util.log.Logger;

import mx.effects.easing.Circular;

/**
 * How different actors should react on the pistol shell hit
 *
 * @author Oleksiy Dyagilev (aka.fe2s@gmail.com)
 */
public class PistolShellHitAction implements Action{

    private var log:Logger = Logger.getLogger();

    private var shell:PistolShell;
    private var world:GameEnvironment;

    public function PistolShellHitAction(shell:PistolShell, world:GameEnvironment) {
        this.shell = shell;
        this.world = world;
    }

    /**
     * Shell may hit the player
     *
     * @param player target player
     */
    public function applyToSimplePlayer(player:SimplePlayer):void {

        var playerModel:SimplePlayerModel = SimplePlayerModel(player.model);
        var shellModel:PistolShellModel = PistolShellModel(shell.model);

        var hit:Boolean = new Circle(playerModel.position, PlayerConstants.RADIUS)
                .isInside(shellModel.position);

        if (hit) {
            // updating only mine models
            if (world.isMineActor(player)){
                var isLive:Boolean = player.hit(PistolShellConstants.DAMAGE);
                if (!isLive) {
                    player.respawn();
                }
            }
            
            // remove shell from this client, it won't be removed from other clients!
            world.remove(shell);
        }
    }

    /**
     * Shells do not affect each other
     *
     * @param shell
     */
    public function applyToPistolShell(shell:PistolShell):void {
        // nothing to do
    }
}
}