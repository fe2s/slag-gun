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
 * User: Dmitry Brazhnik
 */
package com.slaggun.monitor {
public class TimeMonitor extends Monitor{
    private var lastTime:Number;
    private var measure:Boolean = false;

    public function TimeMonitor(data) {
        super(data);
    }

    protected override function initValue(){
        value = 0;
    }

    public function startMeasure(){
        if(!measure){
            lastTime = new Date().time;
            measure = true;
        }
    }

    public function stopMeasure(){
        if(measure){
            value += new Date().time - lastTime;
            measure = false;
        }
    }

    public override function commit(){
        stopMeasure();
        super.commit();
    }
}
}
