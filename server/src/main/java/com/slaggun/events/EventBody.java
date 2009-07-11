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

import java.util.Arrays;

/**
 * @author Oleksiy Dyagilev (aka.fe2s@gmail.com)
 */
public class EventBody {

    private byte[] content;

    public EventBody(byte[] content) {
        this.content = content;
    }

    /**
     * @return size of the boyd in bytes
     */
    public int getSize(){
        return content.length;
    }

    public byte[] getContent() {
        return content;
    }

    public void setContent(byte[] content) {
        this.content = content;
    }

    @Override
    public String toString() {
        return "EventBody{" +
                "content=" + (content == null ? null : Arrays.toString(content)) +
                '}';
    }
}
