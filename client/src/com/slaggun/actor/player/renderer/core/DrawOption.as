/*
 * Copyright 2010 SlagGunTeam
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
 * Unless required by applicable law or agreed to in writing, software distributed under the
 * License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND,
 * either express or implied. See the License for the specific language governing permissions
 * and limitations under the License.
 */

package com.slaggun.actor.player.renderer.core {
import flash.geom.Matrix;

/**
 * @author Dmitry Brazhnik (amid.ukr@gmail.com)
 */
public class DrawOption {
    private static const IDENTITY:Matrix = new Matrix();
    private var _matrix : Matrix;

    public function get matrix():Matrix{
        return _matrix != null ? _matrix : IDENTITY;
    }

    private static function safeClone(obj:*):*{
        return obj == null ? null : obj.clone(); 
    }

    public function clone():DrawOption {
        var result:DrawOption = new DrawOption();

        result._matrix = safeClone(this.matrix);

        return result;
    }

    public function setMatrix(matrix:Matrix):DrawOption{
        var result:DrawOption = clone();
        result._matrix = matrix;
        return result;
    }

    public static function create():DrawOption{
        return new DrawOption();
    }
}
}