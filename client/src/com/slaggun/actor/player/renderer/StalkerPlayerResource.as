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

package com.slaggun.actor.player.renderer {
import com.slaggun.actor.base.ActorRenderer;

/**
 * This is renderer for the SimplePlayer
 *
 * Author Dmitry Brazhnik (amid.ukr@gmail.com)
 *
 * @see SimplePlayer
 */
public class StalkerPlayerResource extends DirectedResource{
    
    [Embed(source="res/stalker.png")]
    public static var stalkerResource:Class;

    private static const INSTANCE:StalkerPlayerResource = new StalkerPlayerResource();

    public static function get instance():StalkerPlayerResource {
        return INSTANCE;
    }

    public static function createRenderer():ActorRenderer{
        return new DirectedRenderer(INSTANCE, 1/15);
    }

    /**
     * Creates StalkerPlayerRenderer. For saving memory purpose use instance property instead.     
     */
    public function StalkerPlayerResource() {
        super(new stalkerResource());
    }
}
}