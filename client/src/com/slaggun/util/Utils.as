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

package com.slaggun.util {
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Point;
import flash.text.TextFormat;

import mx.controls.Alert;
import mx.core.IUITextField;
import mx.core.mx_internal;

/**
 * @author Dmitry Brazhnik (amid.ukr@gmail.com)
 */
public class Utils {
    public static function getAvg(arr:Array, size:int = -1):String{
        var avgTime:int;
        var deviationTime:int;

        if(size == -1)
            size = arr.length;


        var i:int;
        for (i = 0; i < size; i++) {
            avgTime += arr[i];
        }

        avgTime /= size;

        deviationTime = 0;

        for (i = 0; i < size; i++) {
            deviationTime += Math.abs(avgTime - arr[i]);
        }

        deviationTime /= size;

        return avgTime + "+/-" + deviationTime;
    }

    public static function getDefault(value:*, def:*):*{
        return value != null?value:def;
    }

    public static function stretchAlert(alert:Alert, alertWidth:int, messageWidth:int):*{
        alert.width = 350;
        alert.callLater(function():void {
            var textField:IUITextField =  IUITextField(alert.mx_internal::alertForm.mx_internal::textField);

            var textFormat:TextFormat = new TextFormat();
            textFormat.align = "center";

            textField.width = 310;
            textField.x = 0;
            textField.setTextFormat(textFormat);
        });
    }

    public static function roateMatrix(x:Number, y:Number):Matrix {
        var point:Point = new Point(x,  y);
        point.normalize(1);
        return new Matrix(x, y, -y, x);
    }

    public static function scalarMull(a:Point, b:Point):Number {
        return a.x * b.x + a.y * b.y;
    }

    public static function getAngle(x:Number, y:Number):Number {
        var angle:Number = Math.atan(((1.0) * y) / x);
        angle = x >= 0 ? angle : angle + Math.PI;
        angle += 2 * Math.PI;
        angle %= 2 * Math.PI;
        return angle;
    }
}
}