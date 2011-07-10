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

package com.slaggun {
import com.slaggun.actor.player.simple.SimplePlayer;
import com.slaggun.actor.player.simple.tasks.Bot;
import com.slaggun.actor.player.simple.tasks.UserControlled;

/**
 * @author Dmitry Brazhnik (amid.ukr@gmail.com)
 */
public class BotShooter extends Game{
    private var mineActor:SimplePlayer;

    override protected function onInitialize():void {
        mineActor = new SimplePlayer();
        mineActor.task = new UserControlled();
        gameActors.add(mineActor);

        //world.gameRenderer.drawAnimationCalibrateGrid = true;
        //addBots(350);
        //addBots(2);
    }

    /**
     * add a number of bots
     */
    private function addBots(number:int): void {

        var i: int;
        for (i = 0; i < number; i++) {
            var bot:SimplePlayer = new SimplePlayer();
            bot.task = new Bot();
            gameActors.add(bot);
        }
    }
}
}
