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
		var inv = GameData.getInstance().inventory.getAllItems();
		if (inv.length != inventoryCount) {
			FlxG.log.add("Refreshing inventory");
			// TODO: Erasing this is really bad. I should think about passing around invneotry data beter.
			for (sprite in members) {
				this.clear();
				this.add(background);
			}

			// Update inventory
			for (item in inv) {
				var newItem = new InventorySprite();
				newItem.inventoryData = item;
				newItem.loadGraphic(item.IconPath);
				add(newItem);
			}

			inventoryCount = inv.length;
		}

		if (FlxCollision.pixelPerfectPointCheck(FlxG.mouse.x, FlxG.mouse.y, background)){
			background.y = backgroundHeight  - rows * 34;
			//FlxG.log.add("Background hover");
		} else {
			background.y = backgroundHeight;
		}
		FlxG.watch.addQuick("Ui Inventory", this.length);

		updateIconPlacement();

		super.update(elapsed);
	}

	private function updateIconPlacement():Void {
		var iconSize = 32;
		var itemNumber = 0;
		var row = 0;
		var padding = 3;
		for (item in members) {
			if (item != background && item != null) {
				//FlxG.log.add("Setting locaiton for item " + x + ":" + row);
				var x = itemNumber*iconSize+padding;
				if (x > background.width) {
					row++;
					itemNumber = 0;
					x = itemNumber*iconSize+padding;
				} else {
					itemNumber++;
				}

				var y = row * iconSize + padding + (background.y + 147);
				item.x = x;
				item.y = y;

				//FlxG.log.add("Which is now at " + item.x + ":" + item.y);
			}
		}

		rows = row + 1;
	}

	
}