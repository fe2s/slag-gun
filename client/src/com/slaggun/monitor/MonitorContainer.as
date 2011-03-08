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

/**
 * Author: Dmitry Brazhnik
 */
package com.slaggun.monitor {
import com.slaggun.util.Utils;
import com.slaggun.util.log.Logger;

import mx.utils.LoaderUtil;

public class MonitorContainer {
    private static const LOG:Logger = Logger.getLogger(MonitorContainer);

    public static const instance:MonitorContainer = new MonitorContainer();

    private var _monitorMap:Object = {};
    private var _monitors:Array = [];

    public function MonitorContainer() {
    }

    public function registerMonitor(monitor:Monitor):void{
        if(_monitorMap[monitor.name] == null){
            _monitorMap[monitor.name] = monitor;
            _monitors.push(monitor);
        }else{
            LOG.error("Monitor +'" + monitor.name + "' is already registered");
        }
    }

    public function get monitors():Array{
        return _monitors;
    }
}
}
