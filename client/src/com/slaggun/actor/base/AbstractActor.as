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

package com.slaggun.actor.base {
import com.slaggun.Game;
import com.slaggun.actor.base.Action;
import com.slaggun.events.ActorSnapshot;
import com.slaggun.events.NewActorSnapshot;
import com.slaggun.events.SimpleActorSnapshot;
import com.slaggun.events.UpdateActorSnapshot;
import com.slaggun.util.NotImplementedException;

import flash.utils.getQualifiedClassName;

/**
 *
 * @author Oleksiy Dyagilev (aka.fe2s@gmail.com)
 */
public class AbstractActor implements Actor {

    public static var NOT_SET_ID:int = -1;
    public static var NOT_SET_OWNER_ID:int = -1;

    protected var _physics:ActorPhysics;
    protected var _renderer:ActorRenderer;
    protected var _model:ActorModel;

    protected var _id:int = NOT_SET_ID;
    protected var _owner:int = NOT_SET_OWNER_ID;

    private var _replicable:Boolean;
    private var _mine:Boolean;
    private var __online:Boolean;

    public function set mine(value:Boolean):void {
        this._mine = value;
    }

    public function get mine():Boolean {
        return _mine;
    }

    public function set replicable(value:Boolean):void {
        this._replicable = value;
    }

    public function get replicable():Boolean {
        return _replicable;
    }

    public function get online():Boolean {
        return __online;
    }

    public function set _online(value:Boolean):void {
        this.__online = value;
    }

    public function createNewSnapshot(game:Game):NewActorSnapshot {
        return new SimpleActorSnapshot(getQualifiedClassName(this), model);
    }

    public function createUpdateSnapshot(game:Game):UpdateActorSnapshot {
        return new SimpleActorSnapshot(getQualifiedClassName(this), model);
    }

    public function retrieveUpdateSnapshot(game:Game, snapshot:UpdateActorSnapshot):void {
        this.model = SimpleActorSnapshot(snapshot).model;
    }

    public function apply(interactAction:Action):void {
        throw new NotImplementedException("AbstractActor.apply() method not implemented. " +
                                          "Probably is not overridden in child");
    }

    public function get physics():ActorPhysics {
        return _physics;
    }

    public function set physics(value:ActorPhysics):void {
        _physics = value;
    }

    public function get renderer():ActorRenderer {
        return _renderer;
    }

    public function set renderer(value:ActorRenderer):void {
        _renderer = value;
    }

    public function get model():ActorModel {
        return _model;
    }

    public function set model(value:ActorModel):void {
        _model = value;
    }

    public function get id():int {
        return _id;
    }

    public function set id(value:int):void {
        _id = value;
    }

    public function get owner():int {
        return _owner;
    }

    public function set owner(value:int):void {
        _owner = value;
    }

}
}