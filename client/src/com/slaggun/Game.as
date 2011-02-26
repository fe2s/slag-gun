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
import com.slaggun.actor.base.Actor;
import com.slaggun.actor.base.ActorSnapshot;
import com.slaggun.events.RequestSnapshotEvent;
import com.slaggun.events.SnapshotEvent;
import com.slaggun.GameNetworking;
import flash.display.DisplayObject;
import flash.geom.Matrix;
import flash.geom.Rectangle;

import com.slaggun.util.log.Logger;

import flash.display.BitmapData;
import flash.display.Shape;
import flash.events.EventDispatcher;
import flash.utils.Dictionary;

import mx.collections.ArrayCollection;

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
        _gameNetworking.addEventListener(SnapshotEvent.INCOMING,                 _gameActors.handleSnapshot);
        _gameNetworking.addEventListener(RequestSnapshotEvent.REQUEST_SNAPSHOT,  _gameActors.handleRequestSnapshot);
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
        _gameActors.prepareActors();
        _gameActors.live(deltaTime);
        _gameRenderer.renderBackground();
        _gameActors.render(deltaTime);
        _gameRenderer.drawDebugLines();
        _gameRenderer.drawDebugLines();
        _gameActors.replicate();
    }

    public function get latency():Number {
        return _gameActors.latency();
    }
}
}