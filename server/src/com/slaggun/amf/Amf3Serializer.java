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

import flex.messaging.io.SerializationContext;
import flex.messaging.io.amf.Amf3Input;
import flex.messaging.io.amf.Amf3Output;
import sun.misc.BASE64Decoder;
import sun.misc.BASE64Encoder;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;

import org.apache.commons.lang.NullArgumentException;

/**
 * Serializer to/from AMF3 format.
 *
 * @author Oleksiy Dyagilev (aka.fe2s@gmail.com)
 */
public class Amf3Serializer implements AmfSerializer {

    private SerializationContext context;

    public Amf3Serializer(SerializationContext context) {
        if (context == null) {
            throw new NullArgumentException("context must not be null");
        }
        this.context = context;
    }

    /**
     * Serialize given object to AMF3 format as Base64 encoded string.
     *
     * @param source object to be serialized
     * @param <T>    type of object being serialized
     * @return Base64 encoded string
     * @throws AmfSerializerException error during serialization
     */
    public <T> String toAmfString(T source) throws AmfSerializerException {
        BASE64Encoder encoder = new BASE64Encoder();
        return encoder.encode(this.<T>toAmfBytes(source));
    }

    /**
     * Serialize given object to AMF3 format as array of bytes.
     *
     * @param source object to be serialized
     * @param <T>    type of object being serialized
     * @return AMF3 as array of bytes
     * @throws AmfSerializerException error during serialization
     */
    public <T> byte[] toAmfBytes(T source) throws AmfSerializerException {
        if (source == null) {
            throw new NullArgumentException("source must not be null");
        }

        ByteArrayOutputStream byteStream = new ByteArrayOutputStream();
        Amf3Output amf3Output = new Amf3Output(context);
        amf3Output.setOutputStream(byteStream);
        byte[] amfBytes;
        try {
            amf3Output.writeObject(source);
            amf3Output.flush();
            amf3Output.close();

            amfBytes = byteStream.toByteArray();
            byteStream.close();
        } catch (IOException e) {
            throw new AmfSerializerException(e);
        }

        return amfBytes;
    }


    /**
     * Serialize AMF3 string to java object.
     *
     * @param amf AMF3 as Base64 encoded string
     * @param <T> type of output java object
     * @return java object that represents given string
     * @throws AmfSerializerException error during serialization
     */
    public <T> T fromAmfString(String amf) throws AmfSerializerException {
        if (amf == null) {
            throw new NullArgumentException("amf must not be null");
        }

        BASE64Decoder decoder = new BASE64Decoder();
        byte[] input;
        try {
            input = decoder.decodeBuffer(amf);
        } catch (IOException e) {
            throw new AmfSerializerException(e);
        }
        return this.<T>fromAmfBytes(input);
    }

    /**
     * Serialize AMF3 bytes to java object.
     *
     * @param amfBytes AMF3 bytes
     * @param <T>      type of output java object
     * @return java object that represents given string
     * @throws AmfSerializerException error during serialization
     */
    public <T> T fromAmfBytes(byte[] amfBytes) throws AmfSerializerException {
        if (amfBytes == null) {
            throw new NullArgumentException("amfBytes must not be null");
        }

        InputStream byteStream = new ByteArrayInputStream(amfBytes);
        Amf3Input amf3Input = new Amf3Input(context);
        amf3Input.setInputStream(byteStream);
        try {
            return (T) amf3Input.readObject();
        } catch (ClassNotFoundException e) {
            throw new AmfSerializerException("Error during AMF3 deserialization," +
                    " can't find corresponding class", e);
        } catch (IOException e) {
            throw new AmfSerializerException(e);
        }
    }

}
