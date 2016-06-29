package components;

import flixel.util.FlxCollision;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.input.mouse.FlxMouseEventManager;

class InteractableComponent implements ActorComponent {

	public var owner:Actor;
	
	public function init(Data:Dynamic):Bool {
		return true;
	}

	public function postInit(){
		FlxMouseEventManager.add(owner, onInteract);
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
	
	public function destroy():Void {
	}

	private function onInteract(s:FlxSprite):Void {
	}
}