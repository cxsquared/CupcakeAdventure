package components;

import flixel.FlxG;

class FridgeComponent extends InteractableComponent {

	var topOpen:Bool = false;
	var bottomOpen:Bool = false;

	var doorCutOff = 81;

	override public function init(Data:Dynamic):Bool {
		super.init(Data);
		//SoundManager.GetInstance().loadSounds(AssetPaths.CabinetSounds__json);
		return true;
	}

	override public function postInit(){
		super.postInit();
	}

	override public function update(DeltaTime:Float) {
		//FlxG.watch.addQuick("left open", leftOpen);
		//FlxG.watch.addQuick("right open", rightOpen);
		super.update(DeltaTime);
	}

	override public function getComponentID():ActorComponentTypes {
		return ActorComponentTypes.FRIDGE; // This number should never be refferenced
	}

	override private function onInteract():Void {
		if (FlxG.mouse.y < owner.y + doorCutOff) {
			topClicked();
		} else {
			bottomClicked();
		}
	}

	private function topClicked():Void {
		if (topOpen) {
			topOpen = false;
			FlxG.sound.play(AssetPaths.closeCabinet__wav);
			if (bottomOpen) {
				owner.animation.play("topAfterBottom", false, true);
			} else {
				owner.animation.play("topOnly", false,  true);
			}
		} else {
			FlxG.sound.play(AssetPaths.openCabinet__wav);
			topOpen = true;
			if (bottomOpen) {
				owner.animation.play("topAfterBottom", false);
			} else {
				owner.animation.play("topOnly", false);
			}
		}
	}

	private function bottomClicked():Void {
		FlxG.log.add("Right Clicked");
		if (bottomOpen) {
			bottomOpen = false;
			FlxG.sound.play(AssetPaths.closeCabinet__wav);
			if (topOpen) {
				owner.animation.play("bottomAfterTop", false, true);
			} else {
				owner.animation.play("bottomOnly", false, true);
			}
		} else {
			bottomOpen = true;
			FlxG.sound.play(AssetPaths.openCabinet__wav);
			if (topOpen) {
				owner.animation.play("bottomAfterTop", false);
			} else {
				owner.animation.play("bottomOnly", false);
			}
		}
	}
}