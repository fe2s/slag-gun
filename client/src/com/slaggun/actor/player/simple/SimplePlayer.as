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

package com.slaggun.actor.player.simple {
import com.slaggun.actor.base.Actor;
import com.slaggun.actor.base.ActorModel;
import com.slaggun.actor.base.ActorPhysics;
import com.slaggun.actor.base.ActorRenderer;

/**
     * This is the first implementation of user controlled game character
     *
     * Author Dmitry Brazhnik (amid.ukr@gmail.com)
     *
     * @see Actor
     * @see SimplePlayerPhysics
     */
    public class SimplePlayer implements Actor{

        private var _physics:ActorPhysics = new SimplePlayerPhysics();
        private var _renderer:ActorRenderer = new SimplePlayerRenderer();
        private var _model:ActorModel = new SimplePlayerModel();

        // TODO: need to introduce smth better than magic numbers 
        private var _id:int = -1;
        private var _owner:int = -1;

        public function get model():ActorModel {
            return _model;
        }

        public function set model(value:ActorModel):void {
            _model = value;
        }

        public function get renderer():ActorRenderer {
            return _renderer;
        }

        public function set renderer(value:ActorRenderer):void {
            _renderer = value;
        }

        public function get physics():ActorPhysics {
            return _physics;
        }


        public function set physics(value:ActorPhysics):void {
            _physics = value;
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