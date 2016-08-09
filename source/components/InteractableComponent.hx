package components;

import flixel.util.FlxCollision;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.input.mouse.FlxMouseEventManager;
import Actor.MOUSEEVENT;

class InteractableComponent implements ActorComponent {

	public var owner:Actor;
	
	public function init(Data:Dynamic):Bool {
		return true;
	}

	public function postInit(){
	}

	public function update(DeltaTime:Float) {
		/*
		if (FlxCollision.pixelPerfectPointCheck(FlxG.mouse.x, FlxG.mouse.y, owner) && FlxG.mouse.justPressed) {
			onInteract();
		}
		*/
	}

	public function getComponentID():ActorComponentTypes {
		FlxG.log.error("Invalid interactable Component");
		return ActorComponentTypes.INVALID; // This number should never be refferenced
	}

	public function onAdd(Owner:Dynamic):Void {
	}

	public function onMouseEvent(e:MOUSEEVENT):Void {
		if (e == MOUSEEVENT.DOWN) {
			onInteract();
		}
	}
	
	public function destroy():Void {
	}

	private function onInteract():Void {
	}

	public function onEnter():Void{
	}

	public function onExit():Void{
	}
}