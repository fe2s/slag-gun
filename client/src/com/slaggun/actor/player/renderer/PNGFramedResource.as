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
import flash.display.BitmapData;
import flash.display.DisplayObject;
import flash.display.IBitmapDrawable;
import flash.geom.Matrix;
import flash.geom.Rectangle;

/**
 * Here some documentation
 */
public class PNGFramedResource {

    private var _boxWidth:int;
    private var _boxHeight:int;
    private var _boxCentexPointX:int;
    private var _boxCentexPointY:int;
    private var _boxXStart:int;
    private var _boxYStart:int;
    private var _image:DisplayObject ;
    private var _xFramesCount:int;
    private var _yFramesCount:int;    

    public function PNGFramedResource(image:DisplayObject) {
        loadVars(image);
    }

    protected function getBoxWidth():int {
        return (image.width-1)/getXFramesCount()-1;
    }

    protected function getBoxHeight():int {
        return (image.height-1)/getYFramesCount()-1;
    }

    protected function getXFramesCount():int {
        return (image.width - getBoxXStart()) / ( getBoxWidth() + 1);
    }

    protected function getYFramesCount():int {
        return (image.height - getBoxYStart()) / ( getBoxHeight() + 1);
    }

    protected function getBoxCentexPointX():int {
        return getBoxWidth()/2;
    }

    protected function getBoxCentexPointY():int {
        return getBoxHeight()/2;
    }

    protected function getBoxXStart():int {
        return 1;
    }

    protected function getBoxYStart():int {
        return 1;
    }

    public function get image():DisplayObject {
        return _image;
    }

    public function get xFramesCount():int {
        return _xFramesCount;
    }

    public function get yFramesCount():int {
        return _yFramesCount;
    }

    protected function loadVars(image:DisplayObject):void {
        this._image = image;
        _boxWidth = getBoxWidth();
        _boxHeight = getBoxHeight();
        _boxCentexPointX = getBoxCentexPointX();
        _boxCentexPointY = getBoxCentexPointY();
        _boxXStart = getBoxXStart();
        _boxYStart = getBoxYStart();
        _xFramesCount = getXFramesCount();
        _yFramesCount = getYFramesCount();
    }

    private function drawRect(dst:BitmapData, dstX: int, dstY:int, src:IBitmapDrawable, srcX:int, srcY:int, srcWidth:int, srcHeight:int):void {
        var matrix:Matrix = new Matrix();
        matrix.translate(dstX - srcX,
                dstY - srcY);

        dst.draw(image, matrix, null, null, new Rectangle(dstX, dstY, srcWidth, srcHeight));
    }

    public function draw(bitmap:BitmapData, x:int, y:int, xFrame:Number, yFrame:Number):void {

        drawRect(bitmap,
                x - _boxCentexPointX,
                y - _boxCentexPointY,
                image,
                _boxXStart + (_boxWidth + 1) * xFrame,
                _boxYStart + (_boxHeight + 1) * yFrame,
                _boxWidth,
                _boxHeight);
    }

}
}