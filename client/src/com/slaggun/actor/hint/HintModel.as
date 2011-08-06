/* Copyright 2011 SlagGunTeam
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
 * Unless required by applicable law or agreed to in writing, software distributed under the
 * License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND,
 * either express or implied. See the License for the specific language governing permissions
 * and limitations under the License.
 */
package com.slaggun.actor.hint {
import com.slaggun.actor.base.ActorModel;

import flash.geom.Point;

/**
 * @author Dmitry Brazhnik (amid.ukr@gmail.com)
 */
[RemoteClass(alias="com.slaggun.actor.hint.HintModel")]
public class HintModel implements ActorModel{

    public var message:String;
    public var point:Point;

    public function HintModel(message:String = null, point:Point = null) {
        this.message = message;
        this.point = point;
    }
}
}
