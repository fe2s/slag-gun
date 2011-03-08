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

package com.slaggun.util {

/**
 * This class is used to simulate multitasking and redistribute time quote per threads.
 *
 * To make this class work it necessary to pass:
 * desirableTimePerEvent - maximum invocation time. It also consider time spent by caller, so it can be easily set for example to 1000/25 to get 25 FPS.
 *
 * @author: Dmitry Brazhnik
 */
public class AsyncThread {

    private var desirableTimePerEvent:Number;

    private var sysTimeSpent:Number = 0;
    private var timeQuote:Number;
    private var timeQuoteSpent:Number = 0;

    public function AsyncThread(desirableTimePerEvent:Number) {
        timeQuote = desirableTimePerEvent;
        this.desirableTimePerEvent = desirableTimePerEvent;
    }

    public function invoke(deltaTime:Number, callback:Function):Number {
        sysTimeSpent = deltaTime - timeQuoteSpent;

        var requestTimeQuote:Number;

        if (sysTimeSpent > desirableTimePerEvent) {
            requestTimeQuote = sysTimeSpent / 10;
        } else {
            requestTimeQuote = (desirableTimePerEvent - sysTimeSpent);
        }

        // This expression is used to disbalance the upper equation,
        // to find maximum possible requestTimeQuote
        requestTimeQuote += 2;

        if (requestTimeQuote < sysTimeSpent / 10) {
            requestTimeQuote = sysTimeSpent / 10;
        }

        timeQuote += requestTimeQuote;

        timeQuoteSpent = 0;

        var eventsCount:int = 0;

        var startEnterFrameTime:Number = new Date().getTime();
        var enterFrameTime:Number = 0;
        while (timeQuote > 0) {
            if (!callback()) {
                timeQuote = 0;
            }

            var currTime:Number = new Date().getTime();
            enterFrameTime = currTime - startEnterFrameTime;
            startEnterFrameTime = currTime;

            timeQuote -= enterFrameTime;
            timeQuoteSpent += enterFrameTime;
            eventsCount++;
        }

        return timeQuoteSpent;
    }
}
}
