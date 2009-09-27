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

package com.slaggun {
import com.slaggun.actor.player.simple.SimplePlayerFactory;
import com.slaggun.actor.player.simple.bot.BotFactory;
import com.slaggun.util.log.Logger;

import flash.display.BitmapData;
import flash.display.Graphics;

/**
 * Lucnher class that integrates game engine and mxml
 *
 * Author Dmitry Brazhnik (amid.ukr@gmail.com)
 *
 * @see com.slaggun.GameEnvironment
 */
public class LauncherClass {

    private var gamePaused:Boolean = true;
    private var lastTime:Date;
    private var world:GameEnvironment = new GameEnvironment();    
    private var log:Logger = Logger.getLogger();


    public function LauncherClass() {
    }

    /**
     * Initialize luncher settings
     * @return
     */
    public function inititalize():void {

        var playerFactory:SimplePlayerFactory = new SimplePlayerFactory();
        var botFactory:BotFactory = new BotFactory();

        const mineActor:Boolean = true;
        const replicatedOnce:Boolean = false;

        world.add(playerFactory.create(mineActor), mineActor, replicatedOnce);

        //world.drawAnimationCalibrateGrid = true;
        //addBots(350, new BotFactory());

        start();
    }

    /**
     * add a number of bots
     */
    private function addBots(number:int, botFactory:BotFactory): void {
        const mineActor:Boolean = true;
        const replicatedOnce:Boolean = true;
        var i: int;
        for (i = 0; i < number; i++) {
            world.add(botFactory.create(), mineActor, replicatedOnce);
        }
    }

    /**
     * Start game engine simulation
     */
    private function start():void {
        lastTime = new Date();
        gamePaused = false;
    }

    /**
     * Proccess frame
     * @param g - graphics
     * @return time between live cycles
     */
    public function enterFrame(g:Graphics):Number {
        if (!gamePaused) {
            var nowTime:Date = new Date();
            var mils:Number = (nowTime.getTime() - lastTime.getTime());
            if (mils > 1)
            {
                lastTime = nowTime;
                world.live(mils);
            }

            var bitmapData:BitmapData = world.bitmap;
            g.clear();
            g.beginBitmapFill(bitmapData);
            g.drawRect(0, 0, bitmapData.rect.width, bitmapData.rect.height);
            g.endFill();

            return mils;
        }

        return 0;
    }

    public function get latency():Number{
        return world.lalatency;
    }

    /**
     * Handle mouse move events.
     * @param localX - x mouse coordinate
     * @param localY - y mouse coordinate
     * @return
     */
    public function mouseMove(localX:Number, localY:Number):void {
        world.inputStates.updateMousePosition(localX, localY);
//        world.replicate();
    }

    /**
     * Handle keyboard/mouse press down events
     * @param keyCode - keycode
     * @see Keyboard
     */
    public function buttonDown(keyCode:Number):void {
        world.inputStates.pressDown(keyCode);
//        world.replicate();
    }

    /**
     * Handle keyboard/mouse up evemt
     * @param keyCode - key code
     * @return
     */
    public function buttonUp(keyCode:Number):void {
        world.inputStates.pressUp(keyCode);
//        world.replicate();
    }

    /**
     * Handle screen resize
     * @param width - screen width
     * @param height - screen hright
     */
    public function resize(width:Number, height:Number):void {
        world.updateBitMapSize(width, height);
    }

    /**
     * Test connection to game server
     * @return
     */
    public function connect(host:String) : void {
        world.gameClient.connect(host);
    }
}
}