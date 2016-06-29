package components;

import flixel.FlxG;
import flixel.FlxSprite;

class PickUpComponent extends InteractableComponent {

	var description:String;
	var iconPath:String;

	override public function init(Data:Dynamic):Bool {
		super.init(Data);

		description = Reflect.field(Data, "description");
		iconPath = Reflect.field(Data, "iconPath");

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

	override private function onInteract(s:FlxSprite):Void {
		GameData.getInstance().inventory.addNewItem(owner.name, description, owner.getID(), iconPath);
		owner.kill();
	}
}