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

import com.slaggun.util.Assert;

import java.util.Set;
import java.util.HashSet;

/**
 * Event packet extension which also holds a number of recipients.
 *
 * @author Oleksiy Dyagilev (aka.fe2s@gmail.com)
 */
public class OutgoingEventPacket extends EventPacket {

    private Set<Integer> recipientSessionIds;

    public OutgoingEventPacket(EventPacket eventPacket, Set<Integer> recipientSessionIds){
        this(eventPacket.getHeader(), eventPacket.getBody(), recipientSessionIds);
    }

    public OutgoingEventPacket(EventHeader header, EventBody body, Set<Integer> recipientSessionIds) {
        super(header, body);
        Assert.notNull(recipientSessionIds, "recipientSessionIds must not be null");
        this.recipientSessionIds = recipientSessionIds;
    }

    public Set<Integer> getRecipientSessionIds() {
        return recipientSessionIds;
    }

    public void setRecipientSessionIds(Set<Integer> recipientSessionIds) {
        this.recipientSessionIds = recipientSessionIds;
    }
}
