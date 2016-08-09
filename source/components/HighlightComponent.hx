package components;

import flixel.FlxSprite;
import flixel.util.FlxCollision;
import flixel.FlxG;
import flixel.input.mouse.FlxMouseEventManager;
import Actor.MOUSEEVENT;

class HighlightComponent implements ActorComponent {

	public var owner:Actor;
	var highlightSprite:FlxSprite;

	public function init(Data:Dynamic):Bool {
		highlightSprite = new FlxSprite();
		highlightSprite.loadGraphic(Reflect.field(Data, "sprite"));
		highlightSprite.alpha = 0;
		return true;
	}

	public function postInit(){
	}

	public function update(DeltaTime:Float) {
		highlightSprite.x = owner.x;
		highlightSprite.y = owner.y;

		if (!owner.alive && highlightSprite.alive) {
			highlightSprite.kill();
		}
	}

	public function getComponentID():ActorComponentTypes {
		return ActorComponentTypes.HIGHLIGHT; // This number should never be refferenced
	}

	public function onMouseEvent(e:MOUSEEVENT):Void {
		if (e == Actor.MOUSEEVENT.OVER) {
			highlightSprite.alpha = 1;
		} else if (e == Actor.MOUSEEVENT.OUT) {
			highlightSprite.alpha = 0;
		}
	}

	public function onAdd(Owner:Dynamic):Void {
		Owner.add(highlightSprite);
	}

	public function destroy():Void {
		highlightSprite.destroy();
	}

	public function onEnter():Void{
	}

	public function onExit():Void {
	}
}