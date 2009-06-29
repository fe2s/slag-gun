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
import com.slaggun.util.Utils;

import java.util.Arrays;

/**
 * @author Oleksiy Dyagilev (aka.fe2s@gmail.com)
 */
public class EventHeader {

    private int bodySize;
    private byte[] content;

    // number of bytes to fit header, update this value if you change header structure
    public static final int BINARY_SIZE = 4;

    public EventHeader() {
    }

    public EventHeader(int bodySize) {
        this.bodySize = bodySize;
    }

    public EventHeader(byte[] content) {
        Assert.notNull(content, "Content must not be null");
        if (content.length != BINARY_SIZE) {
            throw new IllegalArgumentException("The size of given content " + content.length +
                    " doesn't equal to header size " + BINARY_SIZE);
        }
        this.content = content;
        this.bodySize = Utils.toInt(content);
    }

//    public static int getBodySize(byte[] headerBytes) {
//        Assert.notNull(headerBytes, "Header bytes must no be null");
//        if (headerBytes.length != BINARY_SIZE) {
//            throw new IllegalArgumentException();
//        }
//        return Utils.toInt(headerBytes);
//    }

    public byte[] getContent() {
        if (content == null) {
            return Utils.toBytes(bodySize);
        }
        return content;
    }

    public int getBodySize() {
        return bodySize;
    }

    @Override
    public String toString() {
        return "EventHeader{" +
                "bodySize=" + bodySize +
                ", content=" + (content == null ? null : Arrays.toString(content)) +
                '}';
    }
}
