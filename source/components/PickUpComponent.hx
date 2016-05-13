package components;

import flixel.util.FlxCollision;
import flixel.FlxG;

class PickUpComponent extends InteractableComponent {

	override public function init(Data:Dynamic):Bool {
		return true;
	}

	override public function postInit(){
	}

	override public function update(DeltaTime:Float) {
		if (FlxCollision.pixelPerfectPointCheck(FlxG.mouse.x, FlxG.mouse.y, owner) && FlxG.mouse.justPressed) {
			onInteract();
		}
	}

	override public function getComponentID():Int {
		return 1; // This number should never be refferenced
	}

	override private function onInteract() {
		FlxG.log.add("Component pressed " + this.owner.getID());
	}
}