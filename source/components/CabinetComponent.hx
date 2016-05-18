package components;

import flixel.FlxG;

class CabinetComponent extends InteractableComponent {

	var leftOpen:Bool = false;
	var rightOpen:Bool = false;

	override public function init(Data:Dynamic):Bool {
		super.init(Data);
		return true;
	}

	override public function postInit(){
		super.postInit();
	}

	override public function update(DeltaTime:Float) {
		FlxG.watch.addQuick("left open", leftOpen);
		FlxG.watch.addQuick("right open", rightOpen);
		super.update(DeltaTime);
	}

	override public function getComponentID():ActorComponentTypes {
		return ActorComponentTypes.CABINET; // This number should never be refferenced
	}

	override private function onInteract() {
		if (FlxG.mouse.x < owner.x + owner.width/2) {
			leftClicked();
		} else {
			rightClicked();
		}
	}

	private function rightClicked():Void {
		if (rightOpen) {
			rightOpen = false;
			if (leftOpen) {
				owner.animation.play("rightAfterLeft", false, true);
			} else {
				owner.animation.play("justRightDoor", false,  true);
			}
		} else {
			rightOpen = true;
			if (leftOpen) {
				owner.animation.play("rightAfterLeft", false);
			} else {
				owner.animation.play("justRightDoor", false);
			}
		}
	}

	private function leftClicked():Void {
		FlxG.log.add("Right Clicked");
		if (leftOpen) {
			leftOpen = false;
			if (rightOpen) {
				owner.animation.play("leftAfterRight", false, true);
			} else {
				owner.animation.play("justLeftDoor", false, true);
			}
		} else {
			leftOpen = true;
			if (rightOpen) {
				owner.animation.play("leftAfterRight", false);
			} else {
				owner.animation.play("justLeftDoor", false);
			}
		}
	}
}