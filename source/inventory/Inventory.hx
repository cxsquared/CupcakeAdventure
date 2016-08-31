package inventory;

import flixel.FlxG;
import managers.GameData;

typedef InventoryItem = { Name:String, Description:String, ActorID:Int, IconPath:String };

class Inventory {
	
	var inventoryItems:Map<String,InventoryItem>;

	public function new():Void {
		init();
	}

	private function init():Void {
		inventoryItems = new Map<String,InventoryItem>();
	}

	public function addNewItem(Name:String, Description:String, ActorID:Int, IconPath:String):Void {
		var item = { Name:Name, Description:Description, ActorID:ActorID, IconPath:IconPath };
		addItem(item);
	}

	public function addItem(Item:Inventory.InventoryItem):Void {
		inventoryItems.set(Item.Name, Item);
		FlxG.log.add("Adding item " + Item.Name);
		GameData.getInstance().save();
	}

	// Can return null if item doesn't exist
	public function getItem(Name:String):InventoryItem {
		if (inventoryItems.exists(Name)) {
			var item = inventoryItems.get(Name);
			inventoryItems.remove(Name);
			FlxG.log.add("Getting item " + item.Name);
			GameData.getInstance().save();
			return item;
		}

		return null;
	}

	public function getAllItems():Array<InventoryItem> {
		var inventoryArray:Array<InventoryItem> = new Array<InventoryItem>();

		for (item in inventoryItems) {
			inventoryArray.push(item);
		}

		return inventoryArray;
	}

	public function clear():Void {
		for (item in inventoryItems.keys()) {
			inventoryItems.remove(item);
		}
	}
}