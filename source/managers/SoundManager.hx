package managers;

import flixel.system.FlxSound;
import haxe.Json;
import flixel.FlxG;
import openfl.Assets;
import managers.GameData;

class SoundManager {
	
	private static var instance:SoundManager;

	var soundsMap:Map<String, FlxSound>;

	public static function GetInstance():SoundManager {
		if (instance != null) {
			return instance;
		}

		var sm = new SoundManager();
		SoundManager.instance = sm;
		return instance;
	}

	private function new() {
		soundsMap = new Map<String, FlxSound>();
	}

	public function loadSounds(JSONDataPath:String):Void {

		var jsData = Json.parse(Assets.getText(JSONDataPath));
		var soundData:Array<Dynamic> = Reflect.field(jsData, "sounds");

		for (sound in soundData) {
			var s = new FlxSound();
			FlxG.log.add("loading sound " + Reflect.field(sound, "sound"));
			s.loadEmbedded("assets/sounds/" + Reflect.field(sound, "sound") + ".wav", Reflect.field(sound, "looped"), false);
			s.volume = Reflect.field(sound, "volume");
			soundsMap.set(Reflect.field(sound, "sound"), s);
			FlxG.state.add(s);
		}
	}

	public function playSound(Name:String, ?X:Float=-1, ?Y:Float=-1):FlxSound {
		if (X < 0) {
			X = FlxG.width/2;
		}
		if (Y < 0) {
			Y = FlxG.height/2;
		}
		if (soundsMap.exists(Name)) {
			return soundsMap.get(Name).play(true).proximity(X, Y, GameData.getInstance().player, FlxG.width*.75, true);
		} else {
			FlxG.log.error("The sound " + Name + " isn't loaded in game.");
		}

		return null;
	}

	public function stopSound(Name:String):FlxSound {
		if (soundsMap.exists(Name)) {
			return soundsMap.get(Name).stop();
		} else {
			FlxG.log.error("The sound " + Name + " isn't loaded in game.");
		}

		return null;
	}
}