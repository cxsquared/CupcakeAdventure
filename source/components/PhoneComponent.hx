package components;

import managers.SceneManager;

class PhoneComponent extends SceneChangeComponent {

	var messageWaiting = true;

	override public function init(Data:Dynamic):Bool {
		super.init(Data);


		hideInventory = true;

		return true;
	}

	override public function postInit():Void {
		super.postInit();
		owner.animation.play("phoneAlert");
	}

	override public function getComponentID():ActorComponentTypes {
		return ActorComponentTypes.PHONE;
	}

	override private function onInteract():Void {
		messageWaiting = false;
		owner.animation.play("phoneIdle");
		super.onInteract();
	}
	
}