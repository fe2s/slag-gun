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
import com.slaggun.log.LoggerConfig;
import com.slaggun.log.Priority;

import com.slaggun.log.Logger;
import flash.events.EventDispatcher;

/**
 * This is core game engine class
 *
 * Author Dmitry Brazhnik (amid.ukr@gmail.com)
 */
public class Game extends EventDispatcher {

    private var LOG:Logger = Logger.getLogger(Game);

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
        _gameNetworking.addEventListener(DataRecievedEvent.INCOMING,          _gameActors.onReceive);
        _gameNetworking.addEventListener(DataRecievedEvent.REQUEST_SNAPSHOT,  _gameActors.handleRequestSnapshot);
    }

    protected function initLogger():void{
        LoggerConfig.instance.categories =[
            new Category(LauncherClass, Priority.ERROR,       [LoggerConfig.instance.consoleAppender,  LoggerConfig.instance.textAreaAppender]),
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

    public function enterFrame():Boolean {
        return _gameNetworking.dataHandler(null);
    }

    public function get mapWidth():Number{
        return _gameRenderer.bitmap.width;
    }

    public function get mapHeight():Number{
        return _gameRenderer.bitmap.height;
    }

    /**
     * Process world live iteration
     * @param deltaTime - time pass
     */
    public function live(deltaTime:Number):void {

      Monitors.physicsTime.startMeasure();
        _gameActors.prepareActors();
        _gameActors.live(deltaTime);
      Monitors.physicsTime.stopMeasure();
      Monitors.renderTime.startMeasure();
        _gameRenderer.renderBackground();
        _gameRenderer.drawDebugLines();
        _gameActors.render(deltaTime);
      Monitors.renderTime.stopMeasure();
        _gameActors.replicateActors();
    }

    public function get latency():Number {
        return _gameActors.latency();
    }
}
}