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

package com.slaggun.events;

import com.slaggun.actor.base.ActorModel;

/**
 * @author Oleksiy Dyagilev (aka.fe2s@gmail.com)
 */
public class IdentifiedActorModel {

    private int actorId;
    private int actorOwner;

    private ActorModel actorModel;

    public IdentifiedActorModel() {
    }

    public int getActorId() {
        return actorId;
    }

    public void setActorId(int actorId) {
        this.actorId = actorId;
    }

    public int getActorOwner() {
        return actorOwner;
    }

    public void setActorOwner(int actorOwner) {
        this.actorOwner = actorOwner;
    }

    public ActorModel getActorModel() {
        return actorModel;
    }

    public void setActorModel(ActorModel actorModel) {
        this.actorModel = actorModel;
    }

    @Override
    public String toString() {
        return "IdentifiedActorModel{" +
                "actorId=" + actorId +
                ", actorOwner=" + actorOwner +
                ", actorModel=" + actorModel +
                '}';
    }
}
