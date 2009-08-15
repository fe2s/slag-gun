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

package com.slaggun.actor.player.simple;

import com.slaggun.actor.base.ActorModel;
import com.slaggun.geom.Point2D;
import com.slaggun.geom.Vector2D;

/**
 * @author Oleksiy Dyagilev (aka.fe2s@gmail.com)
 */
public class SimplePlayerModel implements ActorModel {

    private Point2D position;
    private Vector2D velocity;
    private Vector2D look;

    public Point2D getPosition() {
        return position;
    }

    public void setPosition(Point2D position) {
        this.position = position;
    }

    public Vector2D getVelocity() {
        return velocity;
    }

    public void setVelocity(Vector2D velocity) {
        this.velocity = velocity;
    }

    public Vector2D getLook() {
        return look;
    }

    public void setLook(Vector2D look) {
        this.look = look;
    }

    @Override
    public String toString() {
        return "SimplePlayerModel{" +
                "position=" + position +
                ", velocity=" + velocity +
                ", look=" + look +
                '}';
    }
}
