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

/**
 * Serializer to/from AMF format.
 *
 * @author Oleksiy Dyagilev (aka.fe2s@gmail.com)
 */
public interface AmfSerializer {

    /**
     * Serialize given object to AMF format as Base64 encoded string.
     *
     * @param source object to be serialized
     * @param <T> type of object being serialized
     * @return Base64 encoded string
     * @throws AmfSerializerException error during serialization
     */
    <T> String toAmfAsString(T source) throws AmfSerializerException;


    /**
     * Serialize given object to AMF format as array of bytes.
     *
     * @param source object to be serialized
     * @param <T> type of object being serialized
     * @return AMF as array of bytes
     * @throws AmfSerializerException error during serialization
     */
    <T> byte[] toAmf(T source) throws AmfSerializerException;


    /**
     * Serialize AMF string to java object.
     *
     * @param amf AMF as Base64 encoded string
     * @param <T> type of output java object
     * @return java object that represents given string
     * @throws AmfSerializerException error during serialization
     */
    <T> T fromAmf(String amf) throws AmfSerializerException;


    /**
     * Serialize AMF bytes to java object.
     *
     * @param amfBytes AMF bytes
     * @param <T> type of output java object
     * @return java object that represents given string
     * @throws AmfSerializerException error during serialization
     */
    <T> T fromAmf(byte[] amfBytes) throws AmfSerializerException;

}
