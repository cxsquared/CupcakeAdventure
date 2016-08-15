package inventory;

import flixel.FlxSprite;
import flixel.util.FlxCollision;
import flixel.FlxG;
import managers.GameData;

class InventorySprite extends FlxSprite {

	var held = false;

	public var inventoryData:Inventory.InventoryItem;
	
	override public function update(elapsed:Float) {
		super.update(elapsed);

		if (FlxCollision.pixelPerfectPointCheck(FlxG.mouse.x, FlxG.mouse.y, this) && FlxG.mouse.justPressed) {
			held = true;
		}

		if (held && FlxG.mouse.pressed) {
			x = FlxG.mouse.x - this.width/2;
			y = FlxG.mouse.y - this.height/2;
			GameData.getInstance().heldItem = this;
		} else if (held) {
			held = false;
			GameData.getInstance().heldItem = null;
		}
	}

}