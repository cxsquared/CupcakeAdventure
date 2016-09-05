package util;

import haxe.Log;
import flixel.FlxG;

class ObjectUtil {
	private static var instance:ObjectUtil;
	public static function getInstance():ObjectUtil {
		if (instance == null) {
			instance = new ObjectUtil();
		}

		return instance;
	}

	private function new():Void {
	}

	public function printObject(obj:Dynamic):Void {
		var data = Reflect.fields(obj);
		for (field in data) {
			if (Reflect.isObject(Reflect.field(obj, field))) {
				printObject(Reflect.field(obj, field));
			} else {
				Log.trace(field + ":" + Reflect.field(obj, field));
				FlxG.log.add(field + ":" + Reflect.field(obj, field));
			}
		}
	}
}