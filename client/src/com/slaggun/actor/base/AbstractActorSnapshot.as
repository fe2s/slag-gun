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
import com.slaggun.GameEnvironment;
import com.slaggun.util.NotImplementedException;

/**
 *
 * @author Oleksiy Dyagilev (aka.fe2s@gmail.com)
 */
public class AbstractActorSnapshot implements ActorSnapshot{

    protected var _id:int;    
    protected var _model:Object;

    public function resurrect(game:GameEnvironment, owner:int):Actor {
        throw new NotImplementedException("Should be implemented in child");
    }

    public function get id():int {
        return _id;
    }

    public function set id(value:int):void {
        _id = value;
    }

    public function get model():Object {
        return _model;
    }

    public function set model(value:Object):void {
        _model = value;
    }


    public function toString():String {
        return "AbstractActorSnapshot{_id=" + String(_id) + ",_model=" + String(_model) + "}";
    }
}
}