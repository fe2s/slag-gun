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

/**
 * Base interface for the actor.
 * It will live in the world.
 * It can be created with ActorPackage
 *
 * Author Dmitry Brazhnik (amid.ukr@gmail.com)
 *
 * @see PhysicalWorld
 */
package com.slaggun.actor.base {
public interface Actor {


    /**
     * Compact to transportable form
     * 
     * @return transportable actor
     */
    function compact():TransportableActor;
    
    /**
     * Return actor game model
     * @return actor game model
     *
     * @see ActorModel
     */
    function get model():ActorModel;

    /**
     * Set given actor game model
     * @param model model to set
     *
     * @see ActorModel
     */
    function set model(model:ActorModel):void;

    /**
     * Returns actor renderer
     * @return actor renderer
     * @see ActorRenderer
     */
    function get renderer():ActorRenderer;

    /**
     * Sets given actor renderer
     * @see ActorRenderer
     */
    function set renderer(renderer:ActorRenderer):void;

    /**
     * Returns actor physics processor
     * @return actor physics processor
     * @see ActorPhysics
     */
    function get physics():ActorPhysics;

    /**
     * Sets given physics processor
     * @see ActorPhysics
     */
    function set physics(physics:ActorPhysics):void;

    /**
     * @return owner's id. Owner is the player who created the actor.
     * Unique in the scope of world.
     * For now owner id is generated on the server side.
     */
    function get owner():int;

    /**
     * Set owner id
     *
     * @param owner id
     */
    function set owner(owner:int):void;

    /**
     * @return actor id. Unique in the scope of owner.
     * So key {owner, id} - unique identifier in the world
     */
    function get id():int;

    /**
     * @param id set actor's id
     */
    function set id(id:int):void;
}
}