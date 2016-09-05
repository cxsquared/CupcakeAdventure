package components.items;

import flixel.FlxG;
import managers.SoundManager;
import AssetPaths;
import flixel.FlxSprite;
import managers.GameData;

class CabinetComponent extends InteractableComponent {

	var leftOpen:Bool = false;
	var rightOpen:Bool = false;
	var offset:Int = 0;

	override public function init(Data:Dynamic):Bool {
		super.init(Data);
		//SoundManager.GetInstance().loadSounds(AssetPaths.CabinetSounds__json);

		if (Reflect.hasField(Data, "offset")) {
			offset = Reflect.field(Data, "offset");
		}

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

	override private function onInteract():Void {
		if (FlxG.mouse.x < owner.x + owner.width/2 + offset) {
			leftClicked();
		} else {
			rightClicked();
		}
	}

	private function rightClicked():Void {
		if (rightOpen) {
			rightOpen = false;
			FlxG.sound.play(AssetPaths.closeCabinet__wav);
			if (leftOpen) {
				owner.animation.play("rightAfterLeft", false, true);
			} else {
				owner.animation.play("justRightDoor", false,  true);
			}
		} else {
			FlxG.sound.play(AssetPaths.openCabinet__wav);
			rightOpen = true;
			if (leftOpen) {
				owner.animation.play("rightAfterLeft", false);
			} else {
				owner.animation.play("justRightDoor", false);
			}
		}
		onExit();
	}

	private function leftClicked():Void {
		//FlxG.log.add("Right Clicked");
		if (leftOpen) {
			leftOpen = false;
			FlxG.sound.play(AssetPaths.closeCabinet__wav);
			if (rightOpen) {
				owner.animation.play("leftAfterRight", false, true);
			} else {
				owner.animation.play("justLeftDoor", false, true);
			}
		} else {
			leftOpen = true;
			FlxG.sound.play(AssetPaths.openCabinet__wav);
			if (rightOpen) {
				owner.animation.play("leftAfterRight", false);
			} else {
				owner.animation.play("justLeftDoor", false);
			}
		}
		onExit();
	}

	override public function onEnter():Void {
		if (GameData.getInstance().getData(GameData.day, getComponentID()+"leftOpen") == true) {
			leftClicked();
		}
		if (GameData.getInstance().getData(GameData.day, getComponentID()+"rightOpen") == true) {
			rightClicked();
		}
	}

	override public function onExit():Void {
		GameData.getInstance().saveData(GameData.day, getComponentID()+"leftOpen", leftOpen);
		GameData.getInstance().saveData(GameData.day, getComponentID()+"rightOpen", rightOpen);
	}
}