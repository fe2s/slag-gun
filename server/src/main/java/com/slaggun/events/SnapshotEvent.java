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

import java.util.List;

/**
 * @author Oleksiy Dyagilev (aka.fe2s@gmail.com)
 */
public class SnapshotEvent implements GameEvent {

    private List<IdentifiedActorModel> actorModels;

    public SnapshotEvent() {
    }

    public SnapshotEvent(List<IdentifiedActorModel> actorModels) {
        this.actorModels = actorModels;
    }

    public List<IdentifiedActorModel> getActorModels() {
        return actorModels;
    }

    public void setActorModels(List<IdentifiedActorModel> actorModels) {
        this.actorModels = actorModels;
    }

    public void accept(EventVisitor visitor) {
        visitor.visit(this);
    }

    @Override
    public String toString() {
        return "SnapshotEvent{" +
                "actorModels=" + actorModels +
                '}';
    }
}
