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

import flash.display.BitmapData;
import flash.display.Shape;
import flash.geom.Point;

/**
 *
 * @author Oleksiy Dyagilev (aka.fe2s@gmail.com)
 */
public class PistolBullet extends AbstractActor implements Actor, Bullet{

    public function PistolBullet() {
        _model = new PistolBulletModel();
    }

    override public function live(event:GameEvent):void {
        var world:Game = event.game;
        world.shootingService.addBullet(this);

        var shellModel:PistolBulletModel = PistolBulletModel(model);
        shellModel.position.offset(shellModel.speedVector.x, shellModel.speedVector.y);

        var x:Number = shellModel.position.x;
        var y:Number = shellModel.position.y;

        if(x<0 || y<0 || x > world.mapWidth || y > world.mapHeight){
            world.gameActors.remove(this);
        }
    }

    public function get damage():int {
        return Global.BULLET_DAMAGE;
    }

    public function get position():Point {
        return PistolBulletModel(model).position;
    }

    public function scored(event:GameEvent, hitObject:HitObject):void {
        event.game.gameActors.remove(this);
    }

    override public function render(event:GameEvent):void {
        var shellModel:PistolBulletModel = PistolBulletModel(model);

        var circle:Shape = new Shape();
        circle.graphics.beginFill(0);
        circle.graphics.drawCircle(shellModel.position.x, shellModel.position.y, Global.BULLET_RADIUS);
        circle.graphics.endFill();

        event.bitmap.draw(circle);
    }
}
}