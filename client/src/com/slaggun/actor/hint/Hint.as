/* Copyright 2011 SlagGunTeam
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
 * Unless required by applicable law or agreed to in writing, software distributed under the
 * License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND,
 * either express or implied. See the License for the specific language governing permissions
 * and limitations under the License.
 */
package com.slaggun.actor.hint {
import com.slaggun.Game;
import com.slaggun.GameEvent;
import com.slaggun.actor.base.AbstractActor;

import flash.display.BitmapData;
import flash.geom.ColorTransform;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.text.TextField;

/**
 * @author Dmitry Brazhnik (amid.ukr@gmail.com)
 */
public class Hint extends AbstractActor{

    private const initTime:Number = Game.time;
    private const expiration:Number = 1000;

    public function Hint(message:String = null, point:Point = null) {
        this.model = new HintModel(message, point);
    }

    override public function live(event:GameEvent):void {
        var model:HintModel = HintModel(this.model);
        model.point.y -= event.elapsedTime*0.1;

        if(Game.time - initTime > expiration){
            event.game.gameActors.remove(this);
        }
    }

    override public function render(event:GameEvent):void {
        var model:HintModel = HintModel(this.model);
        var bitmap:BitmapData =  event.bitmap;

        var text:TextField = new TextField();
        text.text = model.message;
        text.textColor = 0x00FF00;

        var matrix:Matrix = new Matrix();
        matrix.translate(model.point.x, model.point.y);

        var colorTransform:ColorTransform = new ColorTransform();
        colorTransform.alphaMultiplier = 1 - (Game.time - initTime) / expiration;

        bitmap.draw(text, matrix, colorTransform);
    }
}
}


