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
import com.slaggun.events.AMFRecievedEvent;
import com.slaggun.events.ClientDisconnectedEvent;
import com.slaggun.events.DataRecievedEvent;
import com.slaggun.events.NetworkEvent;
import com.slaggun.events.NewActorSnapshot;
import com.slaggun.events.PackedEvents;
import com.slaggun.events.UpdateActorSnapshot;
import com.slaggun.log.Logger;

import flash.display.BitmapData;
import flash.utils.Dictionary;

import flash.utils.getQualifiedClassName;

/**
 * User: Dmitry Brazhnik
 */
public class GameActors {

    private var LOG:Logger = Logger.getLogger(GameActors);

    // all actors in the world
    private var _actors:Array = [];
    private var _actorsByOwner:Object = {};

    private var nextID:int = 0;

    private function __add(actor:Actor):void {
        _actors.push(actor);

        var ownerActors:Object = _actorsByOwner[actor.owner];

        if(ownerActors == null){
            ownerActors = {};
            ownerActors.actors = [];
            _actorsByOwner[actor.owner] = ownerActors;
        }

        ownerActors[actor.id] = actor;
        ownerActors.actors.push(actor);
        toInit.push(actor);
    }

    private function __remove(actor:Actor):void {
        _actors.splice(_actors.indexOf(actor), 1);

        var ownerActors:Object = _actorsByOwner[actor.owner];

        delete ownerActors[actor.id];
        ownerActors.actors.splice(ownerActors.actors.indexOf(actor), 1);

        if(ownerActors.actors.length == 0){
            delete _actorsByOwner[actor.owner];
        }
    }

    private function __removeOwner(ownerID:int):void {
        var ownerActors:Object = _actorsByOwner[ownerID];
        var actors:Array = ownerActors.actors.concat();
        for(var i:int = 0; i < actors.length; i++){
            try{
                __remove(actors[i]);
            }catch(e:Error){
                LOG.throwError("Can't disconnect actor", e);
            }
        }

        if(ownerActors.actors.length != 0){
            LOG.warn("Assertion fail, ownerActors.actors.length isn't zero");
        }
    }

    private function findActorByID(ownerID:int, actorID:int):Actor{
        var actors:Object = _actorsByOwner[ownerID];
        return actors == null? null : actors[actorID];
    }

    // actors which should be replicated only once
    private var toBeReplicated:Array = [];

    private var toBeAdded:Array = [];
    private var toBeRemoved:Array = [];

    private var toInit:Array = [];

    private var mustBeReplicated:Boolean = false;
    private var repl:int = 0;
    private var _game:Game;

    private var lastReplicateTime:Date = new Date();
    private var _latency:Number;

    public function GameActors(game:Game) {
        this._game = game;
    }

    public function add(actor:Actor, replicatable:Boolean = true):void {
        actor.id = nextID++;
        actor.mine = true;
        actor.owner = -1;
        //_add(actor, true, false);
        toBeAdded.push(actor);

       if(replicatable){
           var event:NewActorSnapshot = actor.createNewSnapshot(_game);
           event.id = actor.id;
           _game.gameNetworking.broadcastAMF(event);
       }

        actor.replicable = replicatable;
        actor._online = replicatable;
    }

    /**
     * Remove actor from the world.
     * If actor is removing during loop it will be remove in the next loop
     * @param actor
     * @return
     */
    public function remove(actor:Actor):void {
        if(actor == null)
            throw new Error("GameActors::remove actor is null");

        toBeRemoved.push(actor);
    }

    public function get actors():Array {
        return _actors;
    }

    /**
     * Add all actors that are waiting
     */
    public function prepareActors():void {

        var len:int = toBeAdded.length;
        var i:int;

        for (i = 0; i < len; i++)
        {
            try{
                __add(toBeAdded[i]);
            }catch(e:Error){
                LOG.throwError("Can't add actor " + toBeRemoved[i], e)
            }
        }

        toBeAdded = [];

        len = toBeRemoved.length;
        for (i = 0; i < len; i++)
        {
            try{
                __remove(toBeRemoved[i])
            }catch(e:Error){
                LOG.throwError("Can't remove actor " + toBeRemoved[i], e)
            }
        }

        toBeRemoved = [];
    }

    public function initActors(event:GameEvent):void {
        for (var i:int = 0; i < toInit.length; i++)
        {
            try{
                Actor(toInit[i]).init(event);
            }catch(e:Error){
                LOG.throwError("Can't init actor " + toInit[i], e)
            }
        }

        for (i = 0; i < toInit.length; i++)
        {
            try{
                var actor:Actor = toInit[i];
                if(actor.task != null){
                    actor.task.initActor(actor, event);
                }

            }catch(e:Error){
                LOG.throwError("Can't run init task for actor " + toInit[i], e)
            }
        }

        toInit = [];
    }

    public function doActorTasks(event:GameEvent):void {
        var len:int = _actors.length;
        for (var i:int = 0; i < len; i++) {
            try{
                var actor:Actor = _actors[i];
                if(actor.task != null){
                    actor.task.controlActor(actor, event);
                }
            }catch(e:Error){
                LOG.throwError("Can't do actor task, actor: " + actor, e);
            }
        }
    }

    public function live(event:GameEvent):void{
        var len:int = _actors.length;
        Monitors.actorsCounter.value = len;
        for (var i:int = 0; i < len; i++) {
            try{
                Actor(_actors[i]).live(event);
            }catch(e:Error){
                LOG.throwError("Can't do actor live, actor: " + _actors[i], e)
            }
        }
    }

    public function render(event:GameEvent):void{
        var bitmap:BitmapData = _game.gameRenderer.bitmap;

        var len:int = _actors.length;
        for (var i:int = 0; i < len; i++) {
            try{
                var actor:Actor = _actors[i];
                actor.render(event);
            }catch(e:Error){
                LOG.throwError("Can't render actor: " + _actors[i], e)
            }
        }
    }

    public function replicate(actor:Actor):void{
        if(!actor.replicable){
            LOG.warn(getQualifiedClassName(actor) + ": replicate msg called for non replicable actor" );
            return;
        }

        if(_game.gameNetworking.connected){
            toBeReplicated.push(actor);
        }
    }

    /**
     * Snapshot of 'my' world
     *
     * @return snapshot event
     */
    public function buildSnapshot(): PackedEvents {
        var actorSnapshots:Array = [];

        var snapshot:UpdateActorSnapshot;

        for each (var actor:Actor in actors) {
            try{
                if(actor.replicable){
                    snapshot = actor.createUpdateSnapshot(_game);
                    snapshot.id = actor.id;
                    actorSnapshots.push(snapshot);
                }
            }catch(e:Error){
                LOG.throwError("Can't replicate actor: " + actor, e);
            }
        }

        for each (var publishOnce:Actor in toBeReplicated) {
            try{
                snapshot = publishOnce.createUpdateSnapshot(_game);
                snapshot.id = publishOnce.id;
                actorSnapshots.push(snapshot);
            }catch(e:Error){
                LOG.throwError("Can't replicate actor: " + actor, e);
            }
        }

        toBeReplicated = [];

        return new PackedEvents(actorSnapshots);
    }

    public function latency():Number{
        return _latency;
    }

    /**
     * Notifies net game client to fire event
     */
    public function replicateActors():void {

        if(!mustBeReplicated)
            return;

        LOG.debug("Replicates count" + repl++);
        _game.gameNetworking.broadcastAMF(buildSnapshot(), false);
        mustBeReplicated = false;
        var lastMilsTime:Number = lastReplicateTime.getTime();
        lastReplicateTime = new Date();
        _latency = lastReplicateTime.getTime() - lastMilsTime;
        Monitors.latency.appendValue(_latency);

    }

    private var replReq:int = 0;

    public function handleRequestSnapshot(event:DataRecievedEvent):void{
        LOG.debug("Replicate requests count" + replReq++);
        // synchronize with enterFrame loop
        mustBeReplicated = true;
    }

    public function handleEvent(sender:int, event:NetworkEvent):void{

        if (event is NewActorSnapshot){
            var newEvent:NewActorSnapshot = NewActorSnapshot(event);

            if(findActorByID(sender, newEvent.id) == null){
                var clientActor:Actor = newEvent.newActor(_game);
                clientActor.id    = newEvent.id;
                clientActor.owner = sender;

                clientActor.mine = false;
                clientActor._online = true;
                clientActor.replicable = false;

                __add(clientActor);
            }
        }

        if(event is UpdateActorSnapshot){
            var updated:UpdateActorSnapshot = UpdateActorSnapshot(event);
            var existingActor:Actor = findActorByID(sender, updated.id);

            if(existingActor != null){
                existingActor.retrieveUpdateSnapshot(_game, updated);
            }
        }else{
            LOG.error('Unknown event retrieved = ' + event);
        }
    }

    /**
     * Handles incoming snapshots
     */
    public function onReceive(snapshotEvent:AMFRecievedEvent):void {

        var sender:int = snapshotEvent.sender;

        var networkEvent:NetworkEvent = snapshotEvent.data;
        var packedEvents:PackedEvents = networkEvent as PackedEvents;

        if(packedEvents != null){
            var events:Array = packedEvents.events;
            for each (var event:NetworkEvent in events) {
                handleEvent(sender, event);
            }
        }else{
            handleEvent(sender, networkEvent);
        }
    }

    public function onClientDisconnected(event:ClientDisconnectedEvent):void {
        __removeOwner(event.disconnectedClientID);
    }
}
}
