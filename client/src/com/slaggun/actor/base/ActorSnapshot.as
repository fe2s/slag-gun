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
import com.slaggun.actor.base.Actor;
import com.slaggun.actor.base.ActorModel;

/**
 * Transportable (fly weight) representation of actor
 * Used for actors transferring over the network
 *
 * @author Oleksiy Dyagilev (aka.fe2s@gmail.com)
 */
[RemoteClass(alias="com.slaggun.actor.base.ActorSnapshot")]
public interface ActorSnapshot {

    /**
     * Resurrect actor.
     * All actor properties which are not present on
     * the snapshot will be reset to default values.
     *
     * @see Actor.makeSnapshot()
     * @return actor
     */
    function resurrect(game:GameEnvironment):Actor;

    function get model():Object;

    function set model(model:Object):void;

    function set owner(owner:int):void;

    function get owner():int;

    function set id(id:int):void;

    function get id():int;

}
}