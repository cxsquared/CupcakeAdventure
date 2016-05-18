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

	override public function getComponentID():ActorComponentTypes {
		return ActorComponentTypes.PICKUP;
	}

	override private function onInteract() {
		FlxG.log.add("Component pressed " + this.owner.getID());
	}
}