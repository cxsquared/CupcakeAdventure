package;

import flixel.system.FlxSound;
import haxe.Json;
import flixel.FlxG;

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

	public function new() {
		if (SoundManager.instance != null){
			SoundManager.instance = this;
			soundsMap = new Map<String, FlxSound>();
		}
	}

	public function loadSounds(Data:String):Void {
		var jsData = Json.parse(Data);
		var soundData:Array<String> = Reflect.field(jsData, "sounds");

		for (sound in soundData) {
			var s = new FlxSound();
			s.loadStream("assets/sounds/" + sound + ".wav", false, false);

			soundsMap.set(sound, s);
		}
	}

	public function playSound(Name:String):FlxSound {
		if (soundsMap.exists(Name)) {
			return soundsMap.get(Name).play(true);
		} else {
			FlxG.log.error("The sound " + Name + " isn't loaded in game.");
		}

		return null;
	}
}