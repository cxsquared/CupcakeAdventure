package util;

import haxe.Log;
import flixel.FlxG;

class ObjectUtil
{
    private static var instance:ObjectUtil;

    public static function getInstance():ObjectUtil
    {
        if (instance == null)
        {
            instance = new ObjectUtil();
        }

        return instance;
    }

    private function new():Void
    {
    }

    public function printObject(obj:Dynamic, topLevel = true):Void
    {
        if (topLevel)
        {
            Log.trace(obj);
            FlxG.log.add(obj);
        }
    }
}