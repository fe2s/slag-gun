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
package com.slaggun {
import com.slaggun.monitor.Monitor;
import com.slaggun.monitor.MonitorContainer;
import com.slaggun.monitor.TimeMonitor;

public class Monitors {
    public static const fps         : Monitor     = new Monitor    ({name: "FPS",
                                                                     color:"red"});
    public static const monitorTime : TimeMonitor = new TimeMonitor({name: "Monitor",
                                                                     commitOnFrame:false});

    public static const networkTime : TimeMonitor = new TimeMonitor({name: "Network time"});
    public static const latency     : Monitor     = new Monitor    ({name: "Latency", size: 100,
                                                                     commitOnFrame:false});
    public static const actorsCounter : TimeMonitor = new TimeMonitor({name: "Actor count"});
    public static const physicsTime : TimeMonitor = new TimeMonitor({name: "Physics"});
    public static const renderTime  : TimeMonitor = new TimeMonitor({name: "Render"});


    public static function commitFrame():void{
        monitorTime.startMeasure();
        var monitors:Array = MonitorContainer.instance.monitors;
        for(var i:int = 0; i < monitors.length; i++){
            var monitor:Monitor = monitors[i];
            if(   monitor.metaData.commitOnFrame == null
               || monitor.metaData.commitOnFrame)
                monitor.commit();
        }
        monitorTime.commit();
    }
}
}
