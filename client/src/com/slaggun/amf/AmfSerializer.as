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

import mx.utils.Base64Decoder;
import mx.utils.Base64Encoder;

/**
 * Serializer to/from AMF3 format.
 *
 * @author Oleksiy Dyagilev (aka.fe2s@gmail.com)
 */
public class AmfSerializer {

    private static var _instance : AmfSerializer;

    public function AmfSerializer() {
        if (_instance != null) {
            throw new Error("AmfSerializer is a singleton class, use instance() instead");
        }
    }

    public static function instance() : AmfSerializer {
        if (_instance == null) {
            registerAliases();
            _instance = new AmfSerializer();
        }
        return _instance;
    }

    /**
     * Register all known class aliases.
     */
    private static function registerAliases() : void {
        //        registerClassAlias("com.slaggun.test.TestBean", TestBean);
    }

    /**
     * Serialize AS object to AMF format as Base64 encoded string
     *
     * @param source AS object
     * @return AMF format as Base64 encoded string
     */
    public function toAmfString(source:Object):String {
        if (source == null) {
            throw new Error("source must not be null");
        }
        var amfBytes:ByteArray = toAmfBytes(source);
        amfBytes.position = 0;
        var encoder:Base64Encoder = new Base64Encoder();
        encoder.encodeBytes(amfBytes);
        return encoder.toString();
    }

    /**
     * Serialize AS object to AMF byte array
     *
     * @param source AS object
     * @return AMF byte array
     */
    public function toAmfBytes(source:Object):ByteArray {
        if (source == null) {
            throw new Error("source must not be null");
        }
        var bytes:ByteArray = new ByteArray();
        bytes.writeObject(source);
        return bytes;
    }

    /**
     * Serialize AMF string to AS object
     *
     * @param amfString Base64 encoded string of AMF format
     * @return AS object that represents given string
     */
    public function fromAmfString(amfString:String):Object {
        if (amfString == null) {
            throw new Error("amfString must not be null");
        }
        var decoder:Base64Decoder = new Base64Decoder();
        decoder.decode(amfString);
        var amfBytes:ByteArray = decoder.drain();
        return fromAmfBytes(amfBytes);
    }

    /**
     * Serialize AMF bytes to AS object
     *
     * @param amfBytes AMF bytes array
     * @return AS object that represents given AMF bytes
     */
    public function fromAmfBytes(amfBytes:ByteArray):Object {
        if (amfBytes == null) {
            throw new Error("amfBytes must not be null");
        }
        amfBytes.position = 0;
        return amfBytes.readObject();
    }

}
}
