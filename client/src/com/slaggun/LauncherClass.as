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
import com.slaggun.util.Utils;
import com.slaggun.util.log.Logger;

import flash.display.BitmapData;
import flash.display.Graphics;
import flash.geom.Point;
import flash.net.registerClassAlias;

/**
 * Lucnher class that integrates game engine and mxml
 *
 * Author Dmitry Brazhnik (amid.ukr@gmail.com)
 *
 * @see com.slaggun.GameEnvironment
 */
public class LauncherClass {
    private static const DESIRABLE_TIME_PER_EVENT:int = 1000/25;

    private var gamePaused:Boolean = true;
    private var lastTime:Date;
    private var world:GameEnvironment = new GameEnvironment();    
    private var log:Logger = Logger.getLogger(LauncherClass);
    private var sysTimeSpent:Number = 0;
    private var timeQuote:Number = DESIRABLE_TIME_PER_EVENT;
    private var timeQuoteSpent:Number = 0;

    private var networkProcessingTimeArray:Array = [];
    private var lastVar:int = -1;

    public function LauncherClass() {
    }

    /**
     * Initialize luncher settings
     * @return
     */
    public function inititalize():void {

        registerClassAlias("com.slaggun.geom.Point2D", Point);        

        var playerFactory:SimplePlayerFactory = new SimplePlayerFactory();
        var botFactory:BotFactory = new BotFactory();

        const mineActor:Boolean = true;
        const replicatedOnce:Boolean = false;

        world.add(playerFactory.create(mineActor), mineActor, replicatedOnce);

        networkProcessingTimeArray.length = 20;

        //world.drawAnimationCalibrateGrid = true;
        //addBots(350, new BotFactory());
    }

    /**
     * add a number of bots
     */
    private function addBots(number:int, botFactory:BotFactory): void {
        const mineActor:Boolean = true;
        const replicatedOnce:Boolean = false;
        var i: int;
        for (i = 0; i < number; i++) {
            world.add(botFactory.create(), mineActor, replicatedOnce);
        }
    }


    /**
     * Start game engine simulation
     */
    public function start():void {
        lastTime = new Date();
        gamePaused = false;
    }

    /**
     * Sleep the thread for the specified time
     * !!!! Must be us only for debug purposes !!!
     * @param delay
     * @return
     */
    private function sleep(delay:int):void{
        var nowTime:Number = new Date().getTime();
        while(delay > (new Date().getTime() - nowTime)){}
    }

    /**
     * Proccess frame
     * @param g - graphics
     * @return time between live cycles
     *
     * @author Dmitry Brazhnik 
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


            //TODO document this algorithm (and protect as personal patent :-D)            
            
            sysTimeSpent = mils - timeQuoteSpent;

            var requestTimeQuote:Number;

            if(sysTimeSpent > DESIRABLE_TIME_PER_EVENT){
                requestTimeQuote = sysTimeSpent / 10;
            }else{
                requestTimeQuote = (DESIRABLE_TIME_PER_EVENT - sysTimeSpent);
            }

            // This expression is disbalance the upper equation,
            // to find maximum possible requestTimeQuote  
            requestTimeQuote += 2;

            if(requestTimeQuote < sysTimeSpent / 10){
                requestTimeQuote = sysTimeSpent/10;
            }

            timeQuote += requestTimeQuote;

            timeQuoteSpent = 0;

            var eventsCount:int = 0;

            var startEnterFrameTime:Number = new Date().getTime();
            var enterFrameTime:Number = 0;            
            while(timeQuote > 0){
                if(!world.enterFrame()){
                    timeQuote = 0;
                }

                var currTime:Number = new Date().getTime();
                enterFrameTime = currTime - startEnterFrameTime;
                startEnterFrameTime = currTime;

                timeQuote -= enterFrameTime;
                timeQuoteSpent += enterFrameTime;
                eventsCount++;
            }

            lastVar = (lastVar + 1) % networkProcessingTimeArray.length;
            networkProcessingTimeArray[lastVar] = timeQuoteSpent;

            return mils;
        }

        return 0;
    }

    public function  get networkProcessingTime():String{
        return Utils.getAvg(networkProcessingTimeArray); 
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
    public function connect(host:String, policyServer:String) : void {
        world.gameClient.connect(host, policyServer);
    }
}
}