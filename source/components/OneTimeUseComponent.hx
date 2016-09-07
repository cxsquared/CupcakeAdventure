package components;

import managers.GameData;
import flixel.FlxG;
import managers.SoundManager;

class OneTimeUseComponent extends InteractableComponent {

	var persistent:Bool = false;
	var animation:String = "";
	var sound:String = "";
	var hasPlayed:Bool = false;

	override public function init(Data:Dynamic):Bool {
		persistent = Reflect.field(Data, "persistent");
		animation = Reflect.field(Data, "animation");
		sound = Reflect.field(Data, "sound");
		return super.init(Data);
	}

	override public function postInit(){
		if (persistent) {
			var isUsed = GameData.getInstance().getData(-1, owner.name + "hasPlayed");
			if (isUsed) {
				hasPlayed = true;
				if (hasPlayed) {
					owner.animation.play(animation, true, false);
				}
			}
		}
	}

	override public function getComponentID():ActorComponentTypes {
		return ActorComponentTypes.ONETIMEUSE;
	}

	override private function onInteract():Void {
		if (!hasPlayed) {
			owner.animation.play(animation);
			hasPlayed = true;
			if (sound != "") {
				SoundManager.GetInstance().playSound(sound, owner.x, owner.y);
			}
			if (persistent) {
				GameData.getInstance().saveData(-1, owner.name + "hasPlayed", true);
			}
		}
	}
	
}