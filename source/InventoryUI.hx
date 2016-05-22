package;

import flixel.group.FlxSpriteGroup;
import flixel.FlxSprite;
import Inventory.InventoryItem;
import flixel.util.FlxCollision;
import flixel.FlxG;

class InventoryUI extends FlxSpriteGroup {

	var backgroundHeight = 94;
	var background:FlxSprite;
	var inventoryCount:Int = 0;
	var rows = 1;

	public function new():Void {
		super();
		background = new FlxSprite(0, backgroundHeight, AssetPaths.backgroundInv__png);
		add(background);
	}

	override public function update(elapsed:Float) {
		var newCount = GameData.getInstance().inventory.getAllItems().length;
		//FlxG.watch.addQuick("inventory count", newCount);
		if (newCount != inventoryCount) {
			// TODO: Erasing this is really bad. I should think about passing around invneotry data beter.
			for (sprite in members) {
				if (sprite != background) {
					members.remove(sprite);
				}
			}
			// Update inventory
			for (itemIndex in 0...newCount) {
				var newItem = new InventorySprite();
				var item = GameData.getInstance().inventory.getAllItems()[itemIndex];
				newItem.inventoryData = item;
				newItem.loadGraphic(item.IconPath);
				add(newItem);
			}
			inventoryCount = newCount;
		}

		if (FlxCollision.pixelPerfectPointCheck(FlxG.mouse.x, FlxG.mouse.y, background)){
			background.y = backgroundHeight  - rows * 34;
			//FlxG.log.add("Background hover");
		} else {
			background.y = backgroundHeight;
		}

		updateIconPlacement();

		//FlxG.watch.addQuick("backgroundY", background.y);

		super.update(elapsed);
	}

	private function updateIconPlacement():Void {
		var iconSize = 32;
		var itemNumber = 0;
		var row = 0;
		var padding = 3;
		for (item in members) {
			if (item != background) {
				var x = itemNumber*iconSize+padding;
				if (x > background.width) {
					row++;
					itemNumber = 0;
					x = itemNumber*iconSize+padding;
				}

				var y = row * iconSize + padding + (background.y + 147);
				item.x = x;
				item.y = y;
			}
		}

		rows = row + 1;
	}

	
}