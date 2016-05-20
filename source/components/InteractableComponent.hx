package components;

import flixel.util.FlxCollision;
import flixel.FlxG;

class InteractableComponent implements ActorComponent {

	public var owner:Actor;
	
	public function init(Data:Dynamic):Bool {
		return true;
	}

	public function postInit(){
	}

	public function update(DeltaTime:Float) {
		if (FlxCollision.pixelPerfectPointCheck(FlxG.mouse.x, FlxG.mouse.y, owner) && FlxG.mouse.justPressed) {
			onInteract();
		}
	}

	public function getComponentID():ActorComponentTypes {
		return ActorComponentTypes.INVALID; // This number should never be refferenced
	}

	public function onAdd(Owner:Dynamic):Void {
	}
	
	public function destory():Void {
	}

	private function onInteract() {
	}
}