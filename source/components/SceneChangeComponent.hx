package components;

import flixel.FlxSprite;
import SceneManager.SceneDirection;
import flixel.FlxG;

class SceneChangeComponent extends InteractableComponent {

	var targetScene:String;
	var direction:SceneDirection;
	var hideInventory:Bool = false;

	override public function init(Data:Dynamic):Bool {
		super.init(Data);

		targetScene = Reflect.field(Data, "target");
		direction = SceneManager.GetInstance().directionStringToType(Reflect.field(Data, "direction"));

		if (Reflect.hasField(Data, "hideInventory")) {
			hideInventory = Reflect.field(Data, "hideInventory");
		}

		return true;
	}

	override public function postInit(){
		super.postInit();
	}

	override public function update(DeltaTime:Float) {
		super.update(DeltaTime);
	}

	override public function getComponentID():ActorComponentTypes {
		return ActorComponentTypes.SCENECHANGE;
	}

	override private function onInteract():Void {
		SceneManager.GetInstance().changeScene(targetScene, direction);
		cast(FlxG.state, PlayState).inventoryUI.visible = !hideInventory;
	}
	
}