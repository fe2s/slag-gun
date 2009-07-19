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

package com.slaggun.net {
import com.slaggun.events.*;
import com.slaggun.amf.AmfSerializer;

import flash.utils.ByteArray;

/**
 * Binary representation of the event.
 * <p/>
 * Structure:
 * [header]
 * [body]
 * 
 * @author Oleksiy Dyagilev (aka.fe2s@gmail.com)
 */
public class EventPacket {

    private var _header:EventHeader;
    private var _body:EventBody;

    public static function of(event:GameEvent):EventPacket {
        var serializer:AmfSerializer = AmfSerializer.instance();
        var eventBytes:ByteArray = serializer.toAmfBytes(event);

        var body:EventBody = new EventBody(eventBytes);
        var header:EventHeader = new EventHeader(body.size);

        return new EventPacket(header, body);
    }

    public function EventPacket(header:EventHeader, body:EventBody) {
        _header = header;
        _body = body;
    }

    public function get content():ByteArray {
        var content:ByteArray = new ByteArray();
        content.writeBytes(_header.content);
        content.writeBytes(_body.content);
        return content;
    }

    public function get header():EventHeader {
        return _header;
    }

    public function set header(value:EventHeader):void {
        _header = value;
    }

    public function get body():EventBody {
        return _body;
    }

    public function set body(value:EventBody):void {
        _body = value;
    }
}
}