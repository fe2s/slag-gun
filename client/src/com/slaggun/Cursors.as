package com.slaggun {
import com.slaggun.log.Logger;

import flash.display.BitmapData;
import flash.geom.Point;
import flash.ui.Mouse;
import flash.ui.MouseCursor;
import flash.ui.MouseCursorData;

import mx.managers.CursorManager;
import mx.managers.CursorManagerPriority;

/**
 *
 * This class is used to protect Launcher from  MouseCursorData not found excpetion.
 *
 * @author Dmitry Brazhnik (amid.ukr@gmail.com)
 */
public class Cursors {
    public function Cursors() {
    }

    public static function loadCursor():void{

    }

    [Embed(source="precise.gif")]
    private static var aimCursor:Class;
    public static const AIM_CURSOR:String = "aim";

    public static var cursorsRegisterd:Boolean = false;

    private static var LOG:Logger = Logger.getLogger(Cursors);

    private static var currentCursor:int;

    public static function registerCursors():void {
        var cursorData:MouseCursorData = new MouseCursorData();
        cursorData.data = new Vector.<BitmapData>(1, true);
        cursorData.data[0] = new aimCursor().bitmapData
        cursorData.hotSpot = new Point(16, 16);
        Mouse.registerCursor(AIM_CURSOR, cursorData);

        cursorsRegisterd = true;
    }

    public static function showAim():void {
        if(cursorsRegisterd){
            Mouse.cursor = AIM_CURSOR;
        }
        else
        {
            currentCursor = CursorManager.setCursor(aimCursor ,CursorManagerPriority.HIGH, -16, -16);
        }

    }

    public static function auto():void {
        if(Cursors.cursorsRegisterd){
            Mouse.cursor = MouseCursor.AUTO;
        }
        else
        {
            CursorManager.removeCursor(currentCursor);
        }
    }
}
}
