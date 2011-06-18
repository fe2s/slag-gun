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
import com.slaggun.actor.player.simple.SimplePlayerModel;
import com.slaggun.actor.player.simple.SimplePlayerPhysics;
import com.slaggun.events.DataRecievedEvent;
import com.slaggun.log.Category;
import com.slaggun.log.CommonCategory;
import com.slaggun.log.LoggerConfig;
import com.slaggun.log.Priority;

import com.slaggun.log.Logger;
import com.slaggun.log.RootCategory;

import com.slaggun.util.AsyncThread;

import flash.display.BitmapData;
import flash.display.Graphics;
import flash.events.EventDispatcher;
import flash.geom.Point;
import flash.net.registerClassAlias;

/**
 * This is core game engine class
 *
 * Author Dmitry Brazhnik (amid.ukr@gmail.com)
 */
public class Game extends EventDispatcher {

    private var LOG:Logger = Logger.getLogger(Game);


    private static const DESIRABLE_TIME_PER_EVENT:int = 1000/25;

    private var gamePaused:Boolean = true;
    private var lastTime:Date;

    private var networkThread:AsyncThread = new AsyncThread(DESIRABLE_TIME_PER_EVENT);


    private var _inputStates:InputState;
    private var _gameNetworking:GameNetworking;
    private var _gameActors:GameActors;
    private var _gameRenderer:GameRenderer;


    public function Game() {
        initLogger();
        create();
        initialize();
    }

    protected function create():void {
        _inputStates    = createInputState();
        _gameNetworking = createGameNetworking();
        _gameActors     = createGameActors();
        _gameRenderer   = createGameRenderer();
    }

    protected function initialize():void {
        registerClassAlias("com.slaggun.geom.Point2D", Point);

        _gameNetworking.addEventListener(DataRecievedEvent.INCOMING,          _gameActors.onReceive);
        _gameNetworking.addEventListener(DataRecievedEvent.REQUEST_SNAPSHOT,  _gameActors.handleRequestSnapshot);
        _gameNetworking.addEventListener(DataRecievedEvent.DISCONNECTED,      _gameActors.onClientDisconnected);

        onInitialize();
    }

    protected function onInitialize():void {

    }

    protected function initLogger():void{
        LoggerConfig.instance.categories =[
            new Category(RootCategory, Priority.INFO,        [LoggerConfig.instance.consoleAppender,  LoggerConfig.instance.textAreaAppender]),
            new Category(CommonCategory, Priority.INFO,       [LoggerConfig.instance.consoleAppender,  LoggerConfig.instance.textAreaAppender]),

            new Category(SimplePlayerPhysics, Priority.DEBUG, [LoggerConfig.instance.textAreaAppender]),
            new Category(SimplePlayerModel, Priority.INFO,    [LoggerConfig.instance.textAreaAppender]),
            new Category(GameNetworking, Priority.DEBUG,      [LoggerConfig.instance.consoleAppender]),
            new Category(Game, Priority.DEBUG,                [LoggerConfig.instance.consoleAppender])
        ];
    }

    protected function createGameRenderer():GameRenderer {
        return new GameRenderer(this);
    }

    protected function createGameActors():GameActors {
        return new GameActors(this);
    }

    protected function createGameNetworking():GameNetworking {
        return new GameNetworking();
    }

    protected function createInputState():InputState {
        return new InputState();
    }

    /**
     * Recreate offscreen buffer
     * @param width - screen width
     * @param height - screen height
     */
    public function resize(width:Number, height:Number):void {
        _gameRenderer.resize(width, height)
    }

    /**
     * Returns input states
     * @return input states
     * @see com.slaggun.InputState
     */
    public function get inputStates():InputState {
        return _inputStates;
    }

    public function get gameRenderer():GameRenderer {
        return _gameRenderer;
    }

    public function get gameActors():GameActors {
        return _gameActors;
    }

    public function get gameNetworking():GameNetworking {
        return _gameNetworking;
    }

    public function get mapWidth():Number{
        return _gameRenderer.bitmap.width;
    }

    public function get mapHeight():Number{
        return _gameRenderer.bitmap.height;
    }

    private function networkHandler():Boolean{
        return _gameNetworking.dataHandler(null);
    }

    public function onLive(deltaTime:Number):void{

    }

    public function get latency():Number {
        return _gameActors.latency();
    }

    /**
     * Process world live iteration
     * @param deltaTime - time pass
     */
    public function live(deltaTime:Number):void {

      Monitors.physicsTime.startMeasure();
        onLive(deltaTime);
        _gameActors.prepareActors();
        _gameActors.doActorTasks(deltaTime);
        _gameActors.live(deltaTime);
      Monitors.physicsTime.stopMeasure();
      Monitors.renderTime.startMeasure();
        _gameRenderer.renderBackground();
        _gameRenderer.drawDebugLines();
        _gameActors.render(deltaTime);
      Monitors.renderTime.stopMeasure();
        _gameActors.replicateActors();
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
                live(mils);
                Monitors.fps.appendValue(1000 / mils);
            }

            var bitmapData:BitmapData = gameRenderer.bitmap;
            g.clear();
            g.beginBitmapFill(bitmapData);
            g.drawRect(0, 0, bitmapData.rect.width, bitmapData.rect.height);
            g.endFill();

            Monitors.networkTime.startMeasure();
            networkThread.invoke(mils, networkHandler);
            Monitors.networkTime.stopMeasure();

            return mils;
        }

        return 0;
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
}
}