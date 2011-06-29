/* Copyright 2011 SlagGunTeam
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
 * Unless required by applicable law or agreed to in writing, software distributed under the
 * License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND,
 * either express or implied. See the License for the specific language governing permissions
 * and limitations under the License.
 */
package com.slaggun.actor.player.simple.presentation {
import com.slaggun.actor.common.DrawOption;
import com.slaggun.actor.common.ImageFramedResource;
import com.slaggun.actor.player.simple.Weapon;
import com.slaggun.util.Utils;

import flash.display.BitmapData;

import flash.display.DisplayObject;
import flash.geom.Matrix;
import flash.geom.Point;

/**
 * @author Dmitry Brazhnik (amid.ukr@gmail.com)
 */
public class GunWeapon extends ImageFramedResource implements Weapon{

    [Embed(source="weapon.png")]
    public static var stalkerResourceClass:Class;
    public static var stalkerResource:DisplayObject = new stalkerResourceClass();

    public function GunWeapon() {
        super(stalkerResource);

    }


    override protected function getFrameWidth():int {
        return getFrameHeight() * 2;
    }

    override protected function getYFramesCount():int {
        return 8;
    }


    override protected function getFrameCentexPointX():int {
        return super.getFrameCentexPointY();
    }

    public function render(bitmap:BitmapData, timePass:Number, mountPoint:Point, lookAt:Point):void {
        var mat:Matrix =  new Matrix();
        mat.rotate(Utils.getAngle(lookAt.x - mountPoint.x, lookAt.y - mountPoint.y));

        draw(bitmap, mountPoint.x,  mountPoint.y, 0, 0, DrawOption.create().setMatrix(mat));
    }
}
}
