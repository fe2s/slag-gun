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

package com.slaggun.actor.shell.pistol {
import com.slaggun.actor.base.ActorModel;
import com.slaggun.geom.Point2d;
import com.slaggun.geom.Vector2d;

/**
 *
 * @author Oleksiy Dyagilev (aka.fe2s@gmail.com)
 */
[RemoteClass(alias="com.slaggun.actor.shell.pistol.PistolShellModel")]
public class PistolShellModel implements ActorModel{

    private var _position:Point2d;
    private var _speedVector:Vector2d;

    public function get position():Point2d {
        return _position;
    }

    public function get speedVector():Vector2d {
        return _speedVector;
    }

    public function set position(value:Point2d):void {
        _position = value;
    }

    public function set speedVector(value:Vector2d):void {
        _speedVector = value;
    }
}
}