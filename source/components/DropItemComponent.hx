package components;

import Inventory.InventoryItem;
import flixel.util.FlxCollision;
import flixel.FlxG;

class DropItemComponent implements ActorComponent {
	
	public var owner:Actor;
	
	public function init(Data:Dynamic):Bool {
		return true;
	}

	public function postInit(){
	}

	public function update(DeltaTime:Float) {
		if (FlxCollision.pixelPerfectPointCheck(FlxG.mouse.x, FlxG.mouse.y, owner) && FlxG.mouse.justReleased && GameData.getInstance().heldItem != null) {
			var item = GameData.getInstance().heldItem;
			onDrop(item);
		}
	}

	public function getComponentID():ActorComponentTypes {
		FlxG.log.error("Invalid dropable Component");
		return ActorComponentTypes.INVALID; // This number should never be refferenced
	}

	public function onAdd(Owner:Dynamic):Void {
	}
	
	public function destory():Void {
	}

	private function onDrop(Item:InventorySprite) {
	}
}