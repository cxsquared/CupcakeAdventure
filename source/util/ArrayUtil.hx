package util;
class ArrayUtil
{
    public static function clear(arr:Array<Dynamic>):Void
    {
        #if (cpp||php)
            arr.splice(0, arr.length);
        #else
            untyped arr.length = 0;
        #end
    }
}
