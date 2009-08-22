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

import com.slaggun.actor.base.TransportableActor;
import com.slaggun.actor.base.ActorModel;
import com.slaggun.util.RemoteClass;

/**
 * @author Oleksiy Dyagilev (aka.fe2s@gmail.com)
 */
@RemoteClass
public class TransportableSimplePlayer implements TransportableActor {

    private ActorModel model;
    private int owner;
    private int id;

    public ActorModel getModel() {
        return model;
    }

    public void setModel(ActorModel model) {
        this.model = model;
    }

    public int getOwner() {
        return owner;
    }

    public void setOwner(int owner) {
        this.owner = owner;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    @Override
    public String toString() {
        return "TransportableSimplePlayer{" +
                "model=" + model +
                ", owner=" + owner +
                ", id=" + id +
                '}';
    }
}
