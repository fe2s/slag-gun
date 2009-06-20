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
 * @see ActorPackage
 */
package com.slaggun.actor.base {
    public interface Actor {

        /**
         * Return actor game model
         * @return actor game model
         *
         * @see ActorModel
         */
        function get model():ActorModel;

        /**
         * Returns actor renderer
         * @return actor renderer
         * @see ActorRenderer
         */
        function get renderer():ActorRenderer;

        /**
         * Returns actor physics processor
         * @return actor physics processor
         * @see ActorPhysics
         */
        function get physics():ActorPhysics;        
    }
}