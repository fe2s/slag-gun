/* Copyright 2011 SlagGunTeam
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
 * @author Dmitry Brazhnik (amid.ukr@gmail.com)
 */
public class BaseActorTask implements ActorTask{

    public function controlActor(actor:Actor, deltaTime:Number, game:Game):void {

    }


    public function initActor(actor:Actor, deltaTime:Number, game:Game):void {
        controlActor(actor, deltaTime, game);
    }
}
}
