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

package com.slaggun.actor.bullet.pistol {
import com.slaggun.Game;
import com.slaggun.GameEvent;
import com.slaggun.Global;
import com.slaggun.actor.base.AbstractActor;
import com.slaggun.actor.base.Actor;
import com.slaggun.shooting.Bullet;
import com.slaggun.shooting.HitObject;
import com.slaggun.util.Utils;

import flash.display.DisplayObject;
import flash.geom.Matrix;
import flash.geom.Point;

/**
 *
 * @author Oleksiy Dyagilev (aka.fe2s@gmail.com)
 */
public class PistolBullet extends AbstractActor implements Actor, Bullet{

    [Embed(source="bullet.png")]
    public static var bulletResourceClass:Class;
    public static var bulletResource:DisplayObject = new bulletResourceClass();

    private var _previousPosition:Point = null;

    public function PistolBullet() {
        _model = new PistolBulletModel();
    }

    override public function live(event:GameEvent):void {
        var shellModel:PistolBulletModel = PistolBulletModel(model);

        var elapsedTime:Number = shellModel.timer.elapsedTime();

        var world:Game = event.game;
        world.shootingService.addBullet(this);

        _previousPosition = shellModel.position.clone();
        shellModel.position.offset(elapsedTime * shellModel.speedVector.x, elapsedTime * shellModel.speedVector.y);

        var x:Number = shellModel.position.x;
        var y:Number = shellModel.position.y;

        if(        x < -world.mapWidth   || y < -world.mapHeight
                || x > 2*world.mapWidth  || y > 2*world.mapHeight){
            world.gameActors.remove(this);
        }
    }

    public function get damage():int {
        return Global.BULLET_DAMAGE;
    }

    public function get previousPosition():Point {
        return _previousPosition;
    }

    public function get position():Point {
        return PistolBulletModel(model).position;
    }

    public function scored(event:GameEvent, hitObject:HitObject, hitPoint:Point):void {
        event.game.gameActors.remove(this);
        PistolBulletModel(model).position = hitPoint;
    }

    override public function render(event:GameEvent):void {
        var shellModel:PistolBulletModel = PistolBulletModel(model);

        var speedVector:Point = shellModel.speedVector;
        var position:Point = shellModel.position;
        var firePoint:Point = shellModel.firePoint;

        var len:Number = position.subtract(firePoint).length;

        var matrix:Matrix = new Matrix();
        matrix.translate(-bulletResource.width, -bulletResource.height /2);
        matrix.scale(len/bulletResource.width, 0.3)
        matrix.rotate(Utils.getAngle(speedVector.x, speedVector.y));
        
        var cutStartPoint:Point = Point.interpolate(position, firePoint, 0.5);

        matrix.translate(position.x, position.y);
        event.bitmap.draw(bulletResource, matrix, null, null, Utils.rectangle(cutStartPoint, position), true);

//        var circle:Shape = new Shape();
//        circle.graphics.beginFill(0);
//        circle.graphics.drawCircle(shellModel.position.x, shellModel.position.y, Global.BULLET_RADIUS);
//        circle.graphics.endFill();
//
//        event.bitmap.draw(circle);
    }
}
}