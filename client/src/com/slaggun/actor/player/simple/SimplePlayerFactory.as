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
import com.slaggun.actor.player.ActorIdGenerator;

/**
     * This is package with SimplePlayer.
     * It must be used to create SimplePlayer
     *
     * Author Dmitry Brazhnik (amid.ukr@gmail.com)
     *
     * @see SimplePlayer
     */
    public class SimplePlayerFactory {

        public function create(mine:Boolean = false):Actor {
            var player:SimplePlayer = new SimplePlayer();
            if (mine){
                player.id = ActorIdGenerator.nextId();
            }

            return player;
        }
    }
}