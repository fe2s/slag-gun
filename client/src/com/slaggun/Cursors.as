package com.slaggun {
import com.slaggun.log.Logger;

import flash.display.BitmapData;
import flash.geom.Point;
import flash.ui.Mouse;
import flash.ui.MouseCursorData;

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

    private static var LOG:Logger = Logger.getLogger(Cursors);

    public static function registerCursor():void {
        var cursorData:MouseCursorData = new MouseCursorData();
        cursorData.data = new Vector.<BitmapData>(1, true);
        cursorData.data[0] = new aimCursor().bitmapData
        cursorData.hotSpot = new Point(16, 16);
        Mouse.registerCursor(AIM_CURSOR, cursorData);
    }
}
}
