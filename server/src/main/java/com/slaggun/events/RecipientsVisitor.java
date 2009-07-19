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

import java.util.Set;

/**
 * Determines recepients for given event
 *
 * @author Oleksiy Dyagilev (aka.fe2s@gmail.com)
 */
public class RecipientsVisitor implements EventVisitor {

    private int eventOwner;
    private Set<Integer> liveSessionIds;
    private Set<Integer> recipients;

    public RecipientsVisitor(int eventOwner, Set<Integer> liveSessionIds) {
        this.eventOwner = eventOwner;
        this.liveSessionIds = liveSessionIds;
    }

    public Set<Integer> getRecipients() {
        return recipients;
    }

    public void visit(SnapshotEvent event) {
        // all except owner
        boolean res = liveSessionIds.remove(eventOwner);
        if (!res) {
            throw new IllegalStateException("Event owner " + eventOwner + " not found among live session ids " +
                    liveSessionIds);
        }
        this.recipients = liveSessionIds;
    }

    public void visit(HzEvent event) {
        this.recipients = liveSessionIds;
    }
}
