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


package com.slaggun {
import flash.display.BitmapData;
import flash.display.DisplayObject;
import flash.display.Shape;
import flash.geom.Matrix;
import flash.geom.Rectangle;

/**
 * User: Dmitry Brazhnik
 */
public class GameRenderer {

    [Embed(source="res/background.png")]
	private var _backgroundClass:Class;
	private var _background:BitmapData;

    private var _bitmap:BitmapData;

    private var _worldWidth:Number;
    private var _worldHeight:Number;

    private var _drawAnimationCalibrateGrid:Boolean;

    public function GameRenderer(game:Game) {
    }

    protected function createBackground(width:Number, height:Number):BitmapData{
        var result:BitmapData = new BitmapData(width, height);
        var _template:DisplayObject = new _backgroundClass();

        var matrix:Matrix = new Matrix();
		for (var i:int = 0; i <= int(width / _template.width); i++ ) {
			for (var j:int = 0; j <= int(height / _template.height); j++ ) {
				matrix.tx = i * _template.width;
				matrix.ty = j * _template.height;
				result.draw(_template, matrix, null, null, new Rectangle(0, 0, width, height), false);
			}
		}

        return result;
    }


    /**
     * Returns true if gird for calibarting animation is drawn
     * @return true if gird for calibarting animation is drawn
     */
    public function get drawAnimationCalibrateGrid():Boolean {
        return _drawAnimationCalibrateGrid;
    }

    /**
     * Shows or hides animation calibraion grid
     * @param value - if true, calibraion grid will be drawn
     */
    public function set drawAnimationCalibrateGrid(value:Boolean):void {
        _drawAnimationCalibrateGrid = value;
    }

    /**
     * Recreate offscreen buffer
     * @param width - screen width
     * @param height - screen height
     */
    public function resize(width:Number, height:Number):void {
        _bitmap = new BitmapData(width, height);
        _worldWidth = width;
        _worldHeight = height;

        _background = createBackground(width, height);
    }

/**
     * Returns offscreen buffer
     * @return offscreen buffer
     */
    public function get bitmap():BitmapData {
        return _bitmap;
    }

    public function renderBackground():void {
        _bitmap.draw(_background, null, null, null, new Rectangle(0, 0, _background.width, _background.height), false);
	}

    public function drawDebugLines():void {
        if(!_drawAnimationCalibrateGrid)
            return;

        var debugShape:Shape = new Shape();

        debugShape.graphics.lineStyle(1, 0x0000AA);

        const w:int = 30;
        var n:int = _bitmap.width / w;

        for (var i:int = 0; i < n; i++) {
            debugShape.graphics.moveTo(i * w, 0);
            debugShape.graphics.lineTo(i * w, bitmap.width);
        }

        _bitmap.draw(debugShape);
    }

}
}
