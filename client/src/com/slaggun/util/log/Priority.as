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

package com.slaggun.util.log {
/**
 *
 * @author Oleksiy Dyagilev (aka.fe2s@gmail.com)
 */
public class Priority {

    public static const DEBUG:Priority = new Priority(0);
    public static const INFO:Priority = new Priority(1);
    public static const ERROR:Priority = new Priority(2);

    private var level:int;

    public function Priority(level:int) {
        this.level = level;
    }

    public function greaterOrEqualThan(another:Priority):Boolean {
        return level >= another.level;
    }


}
}