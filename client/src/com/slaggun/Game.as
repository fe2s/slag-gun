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
import com.slaggun.events.DataRecievedEvent;
import com.slaggun.log.Category;
import com.slaggun.log.CommonCategory;
import com.slaggun.log.Logger;
import com.slaggun.log.LoggerConfig;
import com.slaggun.log.Priority;
import com.slaggun.log.RootCategory;
import com.slaggun.monitor.Monitor;
import com.slaggun.shooting.ShootingService;
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

    public static var time:Number = new Date().time;


    private static const DESIRABLE_TIME_PER_EVENT:int = 1000/25;

    private var gamePaused:Boolean = true;
    private var lastTime:Date;
    private var timer:Timer = new Timer();

    private var networkThread:AsyncThread = new AsyncThread(DESIRABLE_TIME_PER_EVENT);


    private var _inputStates:InputState;
    private var _gameNetworking:GameNetworking;
    private var _gameActors:GameActors;
    private var _gameRenderer:GameRenderer;
    private var _shootingService:ShootingService;

    private var _services:Array = [];


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

        registerService(_shootingService = createShootingService());
    }

    protected final function initialize():void {
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

            new Category(SimplePlayerModel, Priority.INFO,    [LoggerConfig.instance.textAreaAppender]),
            new Category(GameNetworking, Priority.DEBUG,      [LoggerConfig.instance.consoleAppender]),
            new Category(Game, Priority.DEBUG,                [LoggerConfig.instance.consoleAppender])
        ];
    }

    protected final function registerService(service:GameService):void {
        _services.push(service);
    }

    protected function createShootingService():ShootingService {
        return new ShootingService();
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

    public function get shootingService():ShootingService {
        return _shootingService;
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

    public function onLive(event:GameEvent):void{

    }

    public function get latency():Number {
        return _gameActors.latency();
    }

    private function invokeServices(event:GameEvent):void {
        for(var i:int = 0; i < _services.length; i++){
            try{
                GameService(_services[i]).invoke(event);
            }catch(e:Error){
                LOG.throwError("Can't invoke service " + _services[i], e);
            }
        }
    }

    protected function createGameEvent(now:Date):GameEvent{

        var gameEvent:GameEvent = new GameEvent(this);
        gameEvent._elapsedTime = timer.elapsedTime();
        gameEvent._bitmap = _gameRenderer.bitmap;

        return gameEvent;
    }

    /**
     * Process world live iteration
     * @param deltaTime - time pass
     */
    public function live(now:Date):void {
      Game.time = now.time + _gameNetworking.serverTimeDifference;
      Monitors.serverTime.value = Game.time;

      var gameEvent:GameEvent = createGameEvent(now);

      _gameActors.doActorTasks(gameEvent);
      Monitors.physicsTime.startMeasure();
        onLive(gameEvent);
        _gameActors.prepareActors();
        _gameActors.initActors(gameEvent);
        _gameActors.live(gameEvent);
      Monitors.physicsTime.stopMeasure();
      Monitors.servicesTime.startMeasure();
        invokeServices(gameEvent);
     Monitors.servicesTime.stopMeasure();
      Monitors.renderTime.startMeasure();
        _gameRenderer.renderBackground();
        _gameRenderer.drawDebugLines();
        _gameActors.render(gameEvent);
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
                live(nowTime);
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