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

package com.slaggun.amf {
import flash.utils.ByteArray;

import flexunit.framework.TestCase;

/**
 * @author Oleksiy Dyagilev (aka.fe2s@gmail.com)
 */
public class AmfSerializerTest extends TestCase {

    public function AmfSerializerTest() {
    }

    /**
     * Test AMF bytes round trip.
     */
    public function testAmfBytesRoundTrip() : void {
        var bean:SerializeTestBean = new SerializeTestBean();
        bean.name = "vasiliy";
        bean.age = 25;

        var serializer:AmfSerializer = AmfSerializer.instance();
        var amfBytes:ByteArray = serializer.toAmfBytes(bean);
        var roundTripBean:SerializeTestBean = SerializeTestBean(serializer.fromAmfBytes(amfBytes));
        assertEquals(bean.name, roundTripBean.name);
        assertEquals(bean.age, roundTripBean.age);
    }

    /**
     * Test AMF deserializing from Base64 encoded string.
     */
    public function testFromAmfString() : void {
        // this is a Base64 encoded string that represents SerializeTestBean("vasiliy", 25) in
        // AMF3 format. It was generated on server side utilizing BlazeDS API.
        var amfString:String = "CiNDY29tLnNsYWdndW4uYW1mLlNlcmlhbGl6ZVRlc3RCZWFuCW5hbWUHYWdlBg92YXNpbGl5BBk=";

        var bean:SerializeTestBean = SerializeTestBean(AmfSerializer.instance().fromAmfString(amfString));
        assertEquals(25, bean.age);
        assertEquals("vasiliy", bean.name);
    }


}
}