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
import com.slaggun.actor.base.Actor;
import com.slaggun.actor.base.ActorSnapshot;
import com.slaggun.events.RequestSnapshotEvent;
import com.slaggun.events.SnapshotEvent;
import com.slaggun.log.Logger;

import flash.display.BitmapData;
import flash.utils.Dictionary;

import mx.collections.ArrayCollection;

/**
 * User: Dmitry Brazhnik
 */
public class GameActors {

    private var LOG:Logger = Logger.getLogger(GameActors);

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

    private var mustBeReplicated:Boolean = false;
    private var repl:int = 0;
    private var _game:Game;

    private var lastReplicateTime:Date = new Date();
    private var _latency:Number;

    public function GameActors(game:Game) {
        this._game = game;
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
     * Add all actors that are waiting
     */
    public function prepareActors():void {

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

    public function live(deltaTime:Number):void{
        var len:int = _actors.length;
        Monitors.actorsCounter.value = len;
        for (var i:int = 0; i < len; i++) {
            var actor:Actor = _actors[i];
            if(isMineActor(actor)){
                actor.physics.liveServer(deltaTime, actor, _game);
            }else{
                actor.physics.liveClient(deltaTime, actor, _game);
            }
        }
    }

    public function render(deltaTime:Number):void{
        var bitmap:BitmapData = _game.gameRenderer.bitmap;

        var len:int = _actors.length;
        for (var i:int = 0; i < len; i++) {
            var actor:Actor = _actors[i];
            actor.renderer.draw(deltaTime, actor, bitmap);
        }
    }

/**
     * Snapshot of 'my' world
     *
     * @return snapshot event
     */
    public function buildSnapshot(): SnapshotEvent {
        var actorSnapsots:ArrayCollection = new ArrayCollection();

        for each (var actor:Actor in _mineActors) {
            actorSnapsots.addItem(actor.makeSnapshot(_game));
        }
        for each (var publishOnce:Actor in toBeReplicatedOnce) {
            actorSnapsots.addItem(publishOnce.makeSnapshot(_game));
        }

        toBeReplicatedOnce = [];

        var snapshot:SnapshotEvent = new SnapshotEvent(SnapshotEvent.OUTGOING);
        snapshot.actorSnapshots = actorSnapsots;

        return snapshot;
    }

    public function latency():Number{
        return _latency;
    }

    /**
     * Notifies net game client to fire event
     */
    public function replicate():void {

        if(!mustBeReplicated)
            return;

        LOG.debug("Replicates count" + repl++);
        _game.gameNetworking.sendEvent(buildSnapshot(), GameNetworking.BROADCAST_ADDRESS);
        mustBeReplicated = false;
        var lastMilsTime:Number = lastReplicateTime.getTime();
        lastReplicateTime = new Date();
        _latency = lastReplicateTime.getTime() - lastMilsTime;
        Monitors.latency.appendValue(_latency);

    }

    private var replReq:int = 0;

    public function handleRequestSnapshot(event:RequestSnapshotEvent):void{
        LOG.debug("Replicate requests count" + replReq++);
        // synchronize with enterFrame loop
        mustBeReplicated = true;
    }

    /**
     * Handles incoming snapshots
     */
    public function handleSnapshot(snapshotEvent:SnapshotEvent):void {
        const mineActor:Boolean = false;
        const replicatedOnce:Boolean = false;

        var owner:int = snapshotEvent.sender;
        var existingActors:Array = actorsByOwner[owner];
        trace("handle owner = " + owner);

        for each (var actorSnapshot:ActorSnapshot in snapshotEvent.actorSnapshots) {

            if (existingActors != null) {
                // known owner, try to find given actor
                var knownActor:Boolean = false;
                for each (var existingActor:Actor in existingActors) {
                    if (existingActor.id == actorSnapshot.id) {
                        // found actor, update it
                        existingActor.physics.receiveSnapshot(actorSnapshot.model, existingActor, _game);
                        knownActor = true;
                        break;
                    }
                }
                if (!knownActor) {
                    add(actorSnapshot.resurrect(_game, owner), mineActor, replicatedOnce);
                }
            } else {
                add(actorSnapshot.resurrect(_game, owner), mineActor, replicatedOnce);
            }
        }
    }

}
}
