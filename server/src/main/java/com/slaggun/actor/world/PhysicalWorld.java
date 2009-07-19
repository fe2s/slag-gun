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

package com.slaggun.actor.world;

import com.slaggun.actor.base.ActorModel;
import com.slaggun.events.IdentifiedActorModel;
import com.google.common.collect.HashMultimap;
import com.google.common.collect.Multimap;

import java.util.Set;
import java.util.HashSet;
import java.util.Map;
import java.util.List;

/**
 * @author Oleksiy Dyagilev (aka.fe2s@gmail.com)
 */
public class PhysicalWorld {

    // actors grouped by owner
    Multimap<Integer, IdentifiedActorModel> actorModels = HashMultimap.create();

    public synchronized void updateActors(int owner, List<IdentifiedActorModel> actorModels){
        this.actorModels.replaceValues(owner, actorModels);    
    }
}
