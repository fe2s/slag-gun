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
import com.slaggun.actor.player.ActorIdGenerator;
import com.slaggun.geom.Point2d;
import com.slaggun.geom.Vector2d;

/**
 *
 * @author Oleksiy Dyagilev (aka.fe2s@gmail.com)
 */
public class PistolShellFactory  {

    public function create(startPosition:Point2d, direction:Vector2d, mine:Boolean = false):Actor {

        direction.normalize(PistolShellConstants.SPEED);

        var pistolShell:PistolShell = new PistolShell(startPosition, direction);

        if (mine) {
            pistolShell.id = ActorIdGenerator.nextId();
        }

        return pistolShell;
    }
}
}