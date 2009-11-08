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

/**
 * @author Oleksiy Dyagilev (aka.fe2s@gmail.com)
 */
public class Amf3Factory implements AmfFactory {

    private static Amf3Factory instance = null;
    private static Amf3Serializer serializer = null;

    private Amf3Factory() {
    }

    public static AmfFactory instance(){
        if (instance == null){
            instance = new Amf3Factory();
        }
        return instance;
    }

    public AmfSerializer getAmfSerializer() {
        if (serializer == null){
            serializer = new Amf3Serializer(SerializationContext.getSerializationContext());
        }
        return serializer;
    }


}
