package components;

import Inventory.InventoryItem;
import flixel.util.FlxCollision;
import flixel.FlxG;
import Actor.MOUSEEVENT;

class DropItemComponent implements ActorComponent {
	
	public var owner:Actor;
	private var hovering = false;
	
	public function init(Data:Dynamic):Bool {
		return true;
	}

	public function postInit(){
	}

	public function update(DeltaTime:Float) {
	}

	public function getComponentID():ActorComponentTypes {
		FlxG.log.error("Invalid dropable Component");
		return ActorComponentTypes.INVALID; // This number should never be refferenced
	}

	public function onAdd(Owner:Dynamic):Void {
	}
	
	public function destroy():Void {
	}

	private function onDrop(Item:InventorySprite) {
	}

	public function onMouseEvent(e:MOUSEEVENT):Void{
		if (e == MOUSEEVENT.OVER) {
			hovering = true;
		} else if (e == MOUSEEVENT.OUT) {
			hovering = false;
		}

		if (e == MOUSEEVENT.UP && hovering && GameData.getInstance().heldItem != null) {
			var item = GameData.getInstance().heldItem;
			onDrop(item);
		}
	}
}