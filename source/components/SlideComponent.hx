package components;

import managers.GameData;
import flixel.FlxG;

class SlideComponent extends InteractableComponent {
	
	var direction:String = "";
	var sound:String = "";
	var amount:Int = 0;
	var toggle:Bool = false;
	var hasSlid:Bool = false;

	override public function init(Data:Dynamic):Bool {
		direction = Reflect.field(Data, "dir");
		amount = Reflect.field(Data, "amount");
		sound = Reflect.field(Data, "sound");
		toggle = Reflect.field(Data, "toggle");

		if(direction == "") {
			FlxG.log.error("Slide component on " + owner.name + " " + owner.getID() + " needs a direction.");
			return false;
		}

		return super.init(Data);
	}

	override public function postInit(){
		var isUsed = GameData.getInstance().getData(-1, owner.name + "hasSlid");
		if (isUsed) {
			hasSlid = isUsed;
			if (hasSlid) {
				move();
			}
		}
	}

	override public function getComponentID():ActorComponentTypes {
		return ActorComponentTypes.ONETIMEUSE;
	}

	override private function onInteract():Void {
		if (!hasSlid) {
			hasSlid = true;
			if (sound != "") {
				//TODO: Add sound playing
			}
			GameData.getInstance().saveData(-1, owner.name + "hasSlid", true);
			move();
		} else if (toggle) {
			hasSlid = false;
			if (sound != "") {
				//TODO: Add sound playing
			}
			GameData.getInstance().saveData(-1, owner.name + "hasSlid", false);
			move(true);
		}
	}

	private function move(reversed:Bool=false):Void {
		switch (direction.toLowerCase()) {
			case "left":
				if(reversed){
					owner.x += amount;
				} else {
					owner.x -= amount;
				}
			case "right":
				if(reversed){
					owner.x -= amount;
				} else {
					owner.x += amount;
				}
			case "up":
				if(reversed){
					owner.y += amount;
				} else {
					owner.y -= amount;
				}
			case "down":
				if(reversed){
					owner.y -= amount;
				} else {
					owner.y += amount;
				}
			default:
				FlxG.log.error(direction + " isn't a valid direciton on " + owner.name + " " + owner.getID());
		}
	}
}