package;

import flixel.FlxG;

class GameData {
	
	private static var instance:GameData;
	public var heldItem:InventorySprite;
	public var inventory:Inventory;

	public static function getInstance():GameData {
		if (instance != null) {
			return instance;
		}

		var gd = new GameData();
		instance = gd;

		if (!FlxG.save.bind("CupcakeData")) {
			FlxG.log.error("Save failed to create!");
		}

		return instance;
	}

	private function new():Void {
		inventory = new Inventory();
	}

	// This must be done after actors and scenes have been loaded
	public function load(af:ActorFactory):Void {
		var inventoryData:Array<Inventory.InventoryItem> = FlxG.save.data.inventory;

		for (item in inventoryData) {
			inventory.addItem(item);
			af.getActor(item.ActorID).destroy();
		}
	}

	public function save():Void {
		FlxG.save.data.inventory = inventory.getAllItems();
	}
}