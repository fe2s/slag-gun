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

import com.google.common.collect.BiMap;
import com.google.common.collect.HashBiMap;

/**
 * @author Oleksiy Dyagilev (aka.fe2s@gmail.com)
 */
public class EventTypes {

    private static BiMap<Class<? extends GameEvent>, Integer> eventTypes;

    static {
        eventTypes = HashBiMap.create();
        eventTypes.put(HzEvent.class, 0);
    }

    public static int getType(GameEvent event){
        return eventTypes.get(event.getClass());
    }

    public static Class<? extends GameEvent> getEvent(int type){
        return eventTypes.inverse().get(type);
    }

}
