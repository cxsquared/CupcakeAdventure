package components;

import flixel.FlxG;

class PickUpComponent extends InteractableComponent {

	override public function init(Data:Dynamic):Bool {
		super.init(Data);
		return true;
	}

	override public function postInit(){
		super.postInit();
	}

	override public function update(DeltaTime:Float) {
		super.update(DeltaTime);
	}

	override public function getComponentID():Int {
		return 1; // This number should never be refferenced
	}

	override private function onInteract() {
		FlxG.log.add("Component pressed " + this.owner.getID());
	}
}