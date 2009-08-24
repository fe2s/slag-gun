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
import flash.display.BitmapData;
import flash.display.DisplayObject;
import flash.display.IBitmapDrawable;
import flash.geom.Matrix;
import flash.geom.Rectangle;

/**
 * This is abstract class for png frame resource. This resource is used to draw frame cell from the specified image.
 * Input image must be layouted as table. Each frame cell can be indexed by it's row and col number.
 *
 * <b>NOTE!!!</b> You have to implement: one of the getFrameWidth, getXFramesCount and one of the getFrameHieght, getYFramesCount. 
 * If you will not do that it will be looped, see the description bellow.
 *
 * image.width  = getFrameWidth  * getXFramesCount
 * image.height = getFrameHieght * getYFramesCount
 * So having implemented on of the getFrameWidth , getXFramesCount or getFrameHieght , getYFramesCount,
 * the second one will be implemented accroding to upper eqution.
 *
 * In case of perfomacne issue all neccesary variables are getted while constructing instance.
 * To update them you can invoke loadVars method.
 *
 * @author Dmitry Brazhnik 
 *
 */
public class ImageFramedResource {

    private var _frameWidth:int;
    private var _frameHeight:int;
    private var _frameCentexPointX:int;
    private var _frameCentexPointY:int;
    private var _xStart:int;
    private var _yStart:int;
    private var _image:DisplayObject ;
    private var _xFramesCount:int;
    private var _yFramesCount:int;

    /**
     * Construcst ImageFramedResource with specified resource 
     * @param image
     */
    public function ImageFramedResource(image:DisplayObject) {
        loadVars(image);
    }

    /**
     * Is invoked to get frame width.
     * One of the getFrameWidth or getXFramesCount must be implemented. See class description for more details.  
     * @return a frame width.
     */
    protected function getFrameWidth():int {
        return (image.width-1)/getXFramesCount()-1;
    }

    /**
     * * Is invoked to get frame height.
     * One of the getFrameHeight or getYFramesCount must be implemented. See class description for more details. 
     * @return a frame height.
     */
    protected function getFrameHeight():int {
        return (image.height-1)/getYFramesCount()-1;
    }

    /**
     * Is invoked to get horizontal frames count.
     * One of the getFrameWidth or getXFramesCount must be implemented. See class description for more details.
     * @return horizontal frames count.
     */
    protected function getXFramesCount():int {
        return (image.width - getXStart()) / ( getFrameWidth() + 1);
    }


    /**
     * Is invoked to get vertical frames count.
     * @return vertical frames count.
     */
    protected function getYFramesCount():int {
        return (image.height - getYStart()) / ( getFrameHeight() + 1);
    }

    /**
     * Is invoked to get horizaontal frame center.
     * Above (getFrameCentexPointX, getFrameCentexPointY) frame object will be drawn.
     * By default it is getFrameWidth()/2 
     * @return horizaontal frame center.
     */
    protected function getFrameCentexPointX():int {
        return getFrameWidth()/2;
    }

    /**
     * Is invoked to get vertical frame center.
     * Above (getFrameCentexPointX, getFrameCentexPointY) frame object will be drawn.
     * By default it is getFrameHeight()/2 
     * @return vertical frame center.
     */
    protected function getFrameCentexPointY():int {
        return getFrameHeight()/2;
    }

    /**
     * Is invoked to get x cord of the first frame point that will be drawn
     * By default 1
     * @return x cord of the first frame point that will be drawn
     */
    protected function getXStart():int {
        return 1;
    }

    /**
     * Is invoked to get y cord of the first frame point that will be drawn
     * By default 1
     * @return - y cord of the first frame point that will be drawn
     */
    protected function getYStart():int {
        return 1;
    }

    /**
     * Returns source image
     * @return source image
     */
    public function get image():DisplayObject {
        return _image;
    }

    /**
     * Returns number of frames in horizontal space
     * @return number of frames in horizontal space
     */
    public function get xFramesCount():int {
        return _xFramesCount;
    }

    /**
     * Returns number of frames in vertical space
     * @return number of frames in vertical space
     */
    public function get yFramesCount():int {
        return _yFramesCount;
    }

    /**
     * Updates resource value 
     * @param image - new source image
     */
    protected function loadVars(image:DisplayObject):void {
        this._image = image;
        _frameWidth = getFrameWidth();
        _frameHeight = getFrameHeight();
        _frameCentexPointX = getFrameCentexPointX();
        _frameCentexPointY = getFrameCentexPointY();
        _xStart = getXStart();
        _yStart = getYStart();
        _xFramesCount = getXFramesCount();
        _yFramesCount = getYFramesCount();
    }

    /**
     * Copy rectactange from source image to destination image.
     *
     * @param dst - image to be drawm on
     * @param dstX - upper left x coordinate, of the destination rectangale,
     * @param dstY - upper left y coordinate, of the destination rectangale,
     * @param src - src image that will be copied on dest image
     * @param srcX - upped left x coordinate, of the rectange, that will be copied on destination image.
     * @param srcY - upped left y coordinate, of the rectange, that will be copied on destination image.
     * @param srcWidth - width of the rectange, that will be copied on destination image.
     * @param srcHeight - height of the rectange, that will be copied on destination image.     
     */
    private function drawRect(dst:BitmapData, dstX: int, dstY:int, src:IBitmapDrawable, srcX:int, srcY:int, srcWidth:int, srcHeight:int):void {
        var matrix:Matrix = new Matrix();
        matrix.translate(dstX - srcX,
                dstY - srcY);

        dst.draw(image, matrix, null, null, new Rectangle(dstX, dstY, srcWidth, srcHeight));
    }

    /**
     * Draw specified frame
     * This frame will shifted with (getFrameCentexPointX, getFrameCentexPointy) point.
     * 
     * @param bitmap - bitmap to be drawn on
     * @param x - coordinate, of the upper left corner of the destination rectangle
     * @param y - coordinate, of the upper left corner of the destination rectangle
     * @param xFrame - column index of the frame
     * @param yFrame - row index of the frame     
     */
    public function draw(bitmap:BitmapData, x:int, y:int, xFrame:Number, yFrame:Number):void {

        drawRect(bitmap,
                x - _frameCentexPointX,
                y - _frameCentexPointY,
                image,
                _xStart + (_frameWidth + 1) * xFrame,
                _yStart + (_frameHeight + 1) * yFrame,
                _frameWidth,
                _frameHeight);
    }

}
}