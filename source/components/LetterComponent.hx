package components;

import flixel.tweens.FlxTween;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.util.FlxCollision;

class LetterComponent extends InteractableComponent {

	var letterVisible:Bool = false;
	var letter:FlxSprite;

	override public function init(Data:Dynamic):Bool {
		super.init(Data);

		if (Reflect.hasField(Data, "letterSprite")) {
			letter = new FlxSprite();
			letter.loadGraphic(Reflect.field(Data, "letterSprite"));
		} else {
			FlxG.log.error("Component " + getComponentID() + " needs the data letterSprite.");
			return false;
		}

		if (Reflect.field(Data, "viewOnStart")) {
			letterVisible = true;
		} else {
			letterVisible = false;
			letter.alpha = 0;
		}

		return true;
	}

	override public function postInit(){
		super.postInit();
	}

	override public function update(DeltaTime:Float) {
		super.update(DeltaTime);

		if (FlxG.mouse.justPressed && letterVisible) {
			FlxTween.tween(letter, {alpha:0}, .5, { onComplete:onFadeout });
		}
	}

	override public function getComponentID():ActorComponentTypes {
		return ActorComponentTypes.LETTER;
	}

	override private function onInteract() {
		if (!letterVisible) {
			FlxTween.tween(letter, {alpha:1}, .5, { onComplete:onFadeout });
		}
	}

	private function onFadeout(t:FlxTween):Void
	{
		letterVisible = !letterVisible;
	}

	override public function onAdd(Owner:Dynamic):Void {
		Owner.add(letter);
	}
	
	override public function destory():Void {
		letter.destroy();
	}
	
}