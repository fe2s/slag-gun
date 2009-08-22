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

package com.slaggun.actor.shell.pistol;

import com.slaggun.actor.base.ActorModel;
import com.slaggun.geom.Point2D;
import com.slaggun.geom.Vector2D;
import com.slaggun.util.RemoteClass;

/**
 * @author Oleksiy Dyagilev (aka.fe2s@gmail.com)
 */
@RemoteClass
public class PistolShellModel implements ActorModel{

    private Point2D position;
    private Vector2D speedVector;

    public PistolShellModel() {
        // need for AMF
    }

    public Point2D getPosition() {
        return position;
    }

    public void setPosition(Point2D position) {
        this.position = position;
    }

    public Vector2D getSpeedVector() {
        return speedVector;
    }

    public void setSpeedVector(Vector2D speedVector) {
        this.speedVector = speedVector;
    }

    @Override
    public String toString() {
        return "PistolShellModel{" +
                "position=" + position +
                ", speedVector=" + speedVector +
                '}';
    }
}
