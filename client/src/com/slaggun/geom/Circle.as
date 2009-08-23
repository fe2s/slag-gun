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

package com.slaggun.geom {
import flash.geom.Point;

/**
 *
 * @author Oleksiy Dyagilev (aka.fe2s@gmail.com)
 */
public class Circle {

    private var _center:Point2d;
    private var _radius:Number;

    public function Circle(center:Point2d, radius:Number) {
        _center = center;
        _radius = radius;
    }

    /**
     * Is given point inside the circle ?
     * Boards inclusive comparison.
     *
     * @param point
     * @return true if inside
     */
    public function isInside(point:Point2d):Boolean {
        return Point.distance(point, _center) <= _radius;
    }

    public function get center():Point2d {
        return _center;
    }

    public function set center(value:Point2d):void {
        _center = value;
    }

    public function get radius():Number {
        return _radius;
    }

    public function set radius(value:Number):void {
        _radius = value;
    }
}
}