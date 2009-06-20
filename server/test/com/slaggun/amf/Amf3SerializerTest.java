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

package com.slaggun.amf;

import org.junit.Test;
import junit.framework.TestCase;

/**
 * @author Oleksiy Dyagilev (aka.fe2s@gmail.com)
 */

public class Amf3SerializerTest extends TestCase {

    private SerializeTestBean testBean;

    @Override
    protected void setUp() throws Exception {
        testBean = new SerializeTestBean("vasiliy", 25);
    }

    public void testToFromAmfBytes() throws AmfSerializerException {
        AmfSerializer serializer = Amf3Factory.instance().getAmfSerializer();
        byte[] amf = serializer.toAmf(testBean);
        assertEquals(testBean, serializer.fromAmf(amf));
    }

    public void testToFromAmfString() throws AmfSerializerException {
        AmfSerializer serializer = Amf3Factory.instance().getAmfSerializer();
        String amf = serializer.toAmfAsString(testBean);
        assertEquals(testBean, serializer.fromAmf(amf));
    }

}
