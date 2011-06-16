/*
 * Copyright 2011 SlagGunTeam
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
 * Unless required by applicable law or agreed to in writing, software distributed under the
 * License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND,
 * either express or implied. See the License for the specific language governing permissions
 * and limitations under the License.
 */

package com.slaggun.events {
/**
 * @author Dmitry Brazhnik (amid.ukr@gmail.com)
 */
public class AMFRecievedEvent extends DataRecievedEvent {

    private var _data:NetworkEvent;

    public function AMFRecievedEvent(sender:int, data:NetworkEvent, type:String, bubbles:Boolean = false, cancelable:Boolean = false) {
        super(sender, type, bubbles, cancelable);
        this._data = data;
    }

    public function get data():NetworkEvent{
        return _data;
    }

}
}
