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

package com.slaggun.actor.player.renderer.core {
import flash.display.DisplayObject;

/**
 * This is png file resource for the eight directed concept, for example for player actor.
 *
 * This resource consits of eight rows. Each row is set of animation frames for the row direction.
 * There are 8 rows:
 * The first row represents east direction.
 * The second - south-east direction
 * The thrid - south
 * etc.
 *
 * By default each frame is square, so getBoxWidth is same as getBoxHeigth
 * getBoxHeigth is resource height divided by 8. 
 * 
 */
public class DirectedResource extends ImageFramedResource{
    
    public function DirectedResource(image:DisplayObject) {
        super(image);
    }

    /**
     * Returns ImageFramedResource frame width. Assumed that resource frame is square, so it returns getFrameHeight().
     * @return ImageFramedResource frame width.
     */
    override protected function getFrameWidth():int {
        return super.getFrameHeight();
    }

    /**
     * Returns 8;
     * @return 8
     */
    override protected function getYFramesCount():int {
        return 8;
    }
}
}