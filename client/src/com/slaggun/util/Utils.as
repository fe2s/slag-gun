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

package com.slaggun.util {
/**
 * @author Dmitry Brazhnik (amid.ukr@gmail.com)
 */
public class Utils {
    public static function getAvg(arr:Array):String{
        var avgTime:int;
        var deviationTime:int;

        var size:uint = arr.length;


        var i:int;
        for (i = 0; i < size; i++) {
            avgTime += arr[i];
        }

        avgTime /= size;

        deviationTime = 0;

        for (i = 0; i < size; i++) {
            deviationTime += Math.abs(avgTime - arr[i]);
        }

        deviationTime /= size;

        return avgTime + "+/-" + deviationTime;
    }
}
}