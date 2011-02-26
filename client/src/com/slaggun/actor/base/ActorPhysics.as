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

    /**
     * This class proccess physical proccess of the Actor
     *
     * Author Dmitry Brazhnik (amid.ukr@gmail.com)
     *
     * @see Actor
     */
    public interface ActorPhysics {

        /**
         * Process world iteration
         * @param deltaTime - time pass
         * @param actor     - actor to be proccessed
         * @param world     - game world
         */
        function liveClient(deltaTime:Number, actor:Actor, world:Game):void;

        /**
         * Process world iteration
         * @param deltaTime - time pass
         * @param actor     - actor to be proccessed
         * @param world     - game world
         */
        function liveServer(deltaTime:Number, actor:Actor, world:Game):void;

        /**
         * Returns actor snapshot object.
         * It will be invoked on server side during replicate cycle.
         * @return actor snapshot object.
         */
        function createSnapshot(actor:Actor, world:Game):Object;

        /**
         * Handles client replicate event
         * @param object
         */
        function receiveSnapshot(object:Object, actor:Actor, world:Game):void;
    }
}