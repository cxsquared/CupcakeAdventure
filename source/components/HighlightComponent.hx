package components;

import flixel.FlxSprite;
import flixel.util.FlxCollision;
import flixel.FlxG;

class HighlightComponent implements ActorComponent {

	public var owner:Actor;
	var highlightSprite:FlxSprite;

	public function init(Data:Dynamic):Bool {
		highlightSprite = new FlxSprite();
		highlightSprite.loadGraphic(Reflect.field(Data, "sprite"));
		return true;
	}

	public function postInit(){
	}

	public function update(DeltaTime:Float) {
		highlightSprite.x = owner.x;
		highlightSprite.y = owner.y;
		if (FlxCollision.pixelPerfectPointCheck(FlxG.mouse.x, FlxG.mouse.y, owner)) {
			highlightSprite.alpha = 1;
		} else {
			highlightSprite.alpha = 0;
		}

		if (!owner.alive && highlightSprite.alive) {
			highlightSprite.kill();
		}
	}

	public function getComponentID():ActorComponentTypes {
		return ActorComponentTypes.HIGHLIGHT; // This number should never be refferenced
	}

	public function onAdd(Owner:Dynamic):Void {
		Owner.add(highlightSprite);
	}

	public function destroy():Void {
		highlightSprite.destroy();
	}
}