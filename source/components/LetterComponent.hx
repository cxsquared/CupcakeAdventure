package components;

import flixel.tweens.FlxTween;

class LetterComponent extends InteractableComponent {

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
		FlxTween.tween(owner, {alpha:0}, 1, { onComplete:onFadeout });
	}

	private function onFadeout(t:FlxTween):Void
	{
	    owner.kill();
	}
	
}