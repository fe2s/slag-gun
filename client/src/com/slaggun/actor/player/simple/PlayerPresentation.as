/* Copyright 2011 SlagGunTeam
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
 * Unless required by applicable law or agreed to in writing, software distributed under the
 * License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND,
 * either express or implied. See the License for the specific language governing permissions
 * and limitations under the License.
 */
package com.slaggun.actor.player.simple {
import flash.display.BitmapData;
import flash.geom.Point;

/**
 * @author Dmitry Brazhnik (amid.ukr@gmail.com)
 */
public interface PlayerPresentation {
    function get maxSpeed():Number;
    function get hitRadius():Number;

    function weaponDirection(target:SimplePlayerModel):Point;
    function weaponMountPoint(target:SimplePlayerModel):Point;
    function bulletStartPoint(target:SimplePlayerModel):Point;

    function render(deltaTime:Number, target:SimplePlayerModel, bitmap:BitmapData):void;
}
}
