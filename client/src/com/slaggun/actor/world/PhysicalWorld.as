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

import com.slaggun.actor.player.simple.SimplePlayerModel;
import com.slaggun.actor.player.simple.SimplePlayerPackage;
import com.slaggun.events.IdentifiedActorModel;
import com.slaggun.events.SnapshotEvent;

import flash.display.BitmapData;

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

    private var actors:Array = [];

    // belong to myself
    private var mineActors:Array = [];

    // actors grouped by owner, key - owner id, value - Array<Actor>
    private var actorsByOwner:Dictionary = new Dictionary();

    private var toBeAdded:Array = [];
    private var toBeRemoved:Array = [];

    private var _worldWidth:Number;
    private var _worldHeight:Number;


    public function PhysicalWorld() {
        addEventListener(SnapshotEvent.INCOMING, handleSnapshot);
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
     * @return
     */
    public function add(actor:Actor, mine:Boolean):void {
        toBeAdded.push(actor);
        if (mine){
            mineActors.push(actor);
        }
    }

    /**
     * Remove actor to the world.
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
            actors.push(toBeAdded[i]);
        }

        toBeAdded = [];

        len = toBeRemoved.length;
        for (i = 0; i < len; i++)
        {
            var actor:Actor = toBeRemoved[i];
            var actorIndex:Number = actors.indexOf(actor);
            actors.splice(actorIndex, 1);
        }

        toBeRemoved = [];
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

        var len:int = actors.length;
        for (i = 0; i < len; i++)
        {
            actor = actors[i];
            actor.physics.live(deltaTime, actor, this);
        }

        _bitmap.fillRect(_bitmap.rect, 0xFFFFFF);

        len = actors.length;
        for (i = 0; i < len; i++)
        {
            actor = actors[i];
            actor.renderer.draw(deltaTime, actor, _bitmap);
        }
    }

    /**
     * Snapshot of 'my' world, i.e. all my models.
     * @return snapshot event
     */
    public function get snapshot(): SnapshotEvent {
        var mineModels:ArrayCollection = new ArrayCollection();
        for each (var actor:Actor in mineActors) {
            var idActorModel:IdentifiedActorModel = new IdentifiedActorModel();
            idActorModel.actorModel = actor.model;
            idActorModel.actorId = actor.id;

            mineModels.addItem(idActorModel);
        }

        var snapshot:SnapshotEvent = new SnapshotEvent(SnapshotEvent.OUTGOING);
        snapshot.actorModels = mineModels;

        return snapshot;
    }

    /**
     * Handles incoming snapshots
     */
    public function handleSnapshot(snapshotEvent:SnapshotEvent):void {
        var playerPackage:SimplePlayerPackage = new SimplePlayerPackage();

        var newActorModels:ArrayCollection = snapshotEvent.actorModels;

        for each (var newActorModel:IdentifiedActorModel in newActorModels) {
            var owner:int = newActorModel.actorOwner;
            var existingActors:Array = actorsByOwner[owner];

            trace("owner:" + owner + ", id" + newActorModel.actorId);

            var newActor:Actor;
            if (existingActors == null) {
                trace("unknown owner");
                // unknown owner
                // assume we use SimplePlayer only for now
                newActor = playerPackage.createPlayer(false);
                newActor.model = newActorModel.actorModel;
                newActor.id = newActorModel.actorId;

                // add to the world
                add(newActor, false);
                actorsByOwner[owner] = [newActor];
            } else {
                trace("known owner");
                // known owner
                // try to find given actor
                for each (var existingActor:Actor in existingActors) {
                    if (existingActor.id == newActorModel.actorId) {
                        trace("known actor");
                        // found model, update it
                        existingActor.model = newActorModel.actorModel;
                    } else {
                        trace("new actor");
                        // create new actor

                        // assume we use SimplePlayer only for now
                        newActor = playerPackage.createPlayer(false);
                        newActor.model = newActorModel.actorModel;
                        newActor.owner = newActorModel.actorOwner;
                        newActor.id = newActorModel.actorId;

                        // add to the world
                        add(newActor, false);
                        actorsByOwner[owner].push(newActor);
                    }
                }
            }
        }
    }
}
}