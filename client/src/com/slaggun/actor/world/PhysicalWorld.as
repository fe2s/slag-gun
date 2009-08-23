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

package com.slaggun.actor.world {
import com.slaggun.actor.base.Actor;
import com.slaggun.actor.base.ActorSnapshot;
import com.slaggun.events.SnapshotEvent;

import flash.display.BitmapData;
import flash.display.Shape;
import flash.events.EventDispatcher;
import flash.utils.Dictionary;

import mx.collections.ArrayCollection;

/**
 * This is core world engine class
 *
 * Author Dmitry Brazhnik (amid.ukr@gmail.com)
 */
public class PhysicalWorld extends EventDispatcher {

    private var _inputStates:InputState = new InputState();
    private var _bitmap:BitmapData;

    // all actors in the world
    private var _actors:Array = [];

    // actors grouped by owner, key - owner id, value - Array<Actor>
    private var actorsByOwner:Dictionary = new Dictionary();

    // actors belong to myself, we replicate these actors continuously
    private var _mineActors:Array = [];

    // actors which should be replicated only once
    private var toBeReplicatedOnce:Array = [];

    private var toBeAdded:Array = [];
    private var toBeRemoved:Array = [];

    private var _worldWidth:Number;
    private var _worldHeight:Number;

    private var _drawAnimationCalibrateGrid:Boolean;

    public function PhysicalWorld() {
        addEventListener(SnapshotEvent.INCOMING, handleSnapshot);
    }

    /**
     * Returns true if gird for calibarting animation is drawn
     * @return true if gird for calibarting animation is drawn
     */
    public function get drawAnimationCalibrateGrid():Boolean {
        return _drawAnimationCalibrateGrid;
    }

    /**
     * Shows or hides animation calibraion grid
     * @param value - if true, calibraion grid will be drawn
     */
    public function set drawAnimationCalibrateGrid(value:Boolean):void {
        _drawAnimationCalibrateGrid = value;
    }

    /**
     * Recreate offscreen buffer
     * @param width - screen width
     * @param height - screen height
     */
    public function updateBitMapSize(width:Number, height:Number):void {
        _bitmap = new BitmapData(width, height);
        _worldWidth = width;
        _worldHeight = height;
    }

    /**
     * Returns world width
     * @return world width
     */
    public function get width():Number {
        return _worldWidth;
    }

    /**
     * Returns world height
     * @return world height
     */
    public function get height():Number {
        return _worldHeight;
    }

    /**
     * Add actor to the world.
     * If actor is adding during loop it will be active in the next loop
     * @param actor
     * @param mine belongs to myself
     * @param replicateOnce whether to replicate this actor only one time
     * @return
     */
    public function add(actor:Actor, mine:Boolean, replicateOnce:Boolean):void {
        // add to all actors list
        toBeAdded.push(actor);

        if (mine && replicateOnce){
            // most likely logical error as mine actors are replicated continuously
            throw new Error("Illegal arguments. Both mine and replicateOnce params are true");
        }

        // add to mine actors list
        if (mine) {
            _mineActors.push(actor);
        }

        if (replicateOnce) {
            toBeReplicatedOnce.push(actor);
        }

        // add to 'grouped by owner' dictionary
        var owner:int = actor.owner;
        var existingActorsForThisOwner:Array = actorsByOwner[owner];
        if (existingActorsForThisOwner == null) {
            actorsByOwner[owner] = [actor];
        } else {
            actorsByOwner[owner].push(actor);
        }
    }

    /**
     * Remove actor from the world.
     * If actor is removing during loop it will be remove in the next loop
     * @param actor
     * @return
     */
    public function remove(actor:Actor):void {
        toBeRemoved.push(actor);
    }

    /**
     * Returns input states
     * @return input states
     * @see InputState
     */
    public function get inputStates():InputState {
        return _inputStates;
    }

    /**
     * Returns offscreen buffer
     * @return offscreen buffer
     */
    public function get bitmap():BitmapData {
        return _bitmap;
    }

    /**
     * Add all actors that are waiting
     */
    private function addAll():void {

        var actorName:String;

        var len:int = toBeAdded.length;
        var i:int;

        for (i = 0; i < len; i++)
        {
            _actors.push(toBeAdded[i]);
        }

        toBeAdded = [];

        len = toBeRemoved.length;
        for (i = 0; i < len; i++)
        {
            var actor:Actor = toBeRemoved[i];
            var actorIndex:Number = _actors.indexOf(actor);
            _actors.splice(actorIndex, 1);
        }

        toBeRemoved = [];
    }

    private function drawDebugLines(bitmap:BitmapData):void {
        var debugShape:Shape = new Shape();

        debugShape.graphics.lineStyle(1, 0x0000AA);

        const w:int = 30;
        var n:int = bitmap.width / w;

        for (var i:int = 0; i < n; i++) {
            debugShape.graphics.moveTo(i * w, 0);
            debugShape.graphics.lineTo(i * w, bitmap.width);
        }

        bitmap.draw(debugShape);
    }

    /**
     * Process world live iteration
     * @param deltaTime - time pass
     */
    public function live(deltaTime:Number):void {
        addAll();

        var actorName:String;
        var actor:Actor;

        var i:int;

        var len:int = _actors.length;
        for (i = 0; i < len; i++) {
            actor = _actors[i];
            actor.physics.live(deltaTime, actor, this);
        }

        _bitmap.fillRect(_bitmap.rect, 0xFFFFFF);

        for (i = 0; i < len; i++) {
            actor = _actors[i];
            actor.renderer.draw(deltaTime, actor, _bitmap);
        }

        if (_drawAnimationCalibrateGrid)
            drawDebugLines(_bitmap);
    }

    /**
     *  Determines whether given actor is mine
     *
     * @param actor
     * @return true if mine, false otherwise
     */
    public function isMineActor(actor:Actor):Boolean {
        for each (var mineActor:Actor in _mineActors) {
            if (mineActor.owner == actor.owner && mineActor.id == actor.id) {
                return true;
            }
        }
        return false;
    }

    public function get mineActors():Array{
        return _mineActors;
    }

    public function get actors():Array {
        return _actors;
    }

    /**
     * Snapshot of 'my' world
     *
     * @return snapshot event
     */
    public function get snapshot(): SnapshotEvent {
        var actorSnapsots:ArrayCollection = new ArrayCollection();

        for each (var actor:Actor in _mineActors) {
            actorSnapsots.addItem(actor.makeSnapshot());
        }
        for each (var publishOnce:Actor in toBeReplicatedOnce) {
            actorSnapsots.addItem(publishOnce.makeSnapshot());
        }

        toBeReplicatedOnce = [];

        var snapshot:SnapshotEvent = new SnapshotEvent(SnapshotEvent.OUTGOING);
        snapshot.actorSnapshots = actorSnapsots;

        return snapshot;
    }

    /**
     * Handles incoming snapshots
     */
    public function handleSnapshot(snapshotEvent:SnapshotEvent):void {
        const mineActor:Boolean = false;
        const replicatedOnce:Boolean = false;
        for each (var actorSnapshot:ActorSnapshot in snapshotEvent.actorSnapshots) {

            var existingActors:Array = actorsByOwner[actorSnapshot.owner];

            if (existingActors != null) {
                // known owner, try to find given actor
                var knownActor:Boolean = false;
                for each (var existingActor:Actor in existingActors) {
                    if (existingActor.id == actorSnapshot.id) {
                        // found actor, update it
                        existingActor.model = actorSnapshot.model;
                        knownActor = true;
                        break;
                    }
                }
                if (!knownActor) {
                    add(actorSnapshot.resurrect(), mineActor, replicatedOnce);
                }
            } else {
                add(actorSnapshot.resurrect(), mineActor, replicatedOnce);
            }
        }
    }
}
}