package components;

import flixel.FlxSprite;

class SceneChangeComponent extends InteractableComponent {

	var targetScene:String;

	override public function init(Data:Dynamic):Bool {
		super.init(Data);

		targetScene = Reflect.field(Data, "target");

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

	override private function onInteract(s:FlxSprite):Void {
		SceneManager.GetInstance().changeScene(targetScene);
	}
	
}