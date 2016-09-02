package managers;

import flixel.FlxG;
import inventory.*;
import actors.*;
import states.PlayState;

class GameData {
	
	private static var instance:GameData;
	public var heldItem:InventorySprite;
	public var inventory:Inventory;

	//public static var MatchThree = new MatchThreeState();
	//public static var PlayScreen = new PlayState();

	@:isVar
	public static var day(get, set):Int = -1;
	private static function get_day():Int {
		if (!Reflect.hasField(FlxG.save.data, "day")) {
			FlxG.save.data.day = 1;
			FlxG.log.add("Initializing day");
			FlxG.save.flush();
			return 1;
		} else if (day == -1) {
			day = 1;
		}

		return FlxG.save.data.day;
	}
	private static function set_day(v:Int):Int {
		FlxG.save.data.day = v;
		day = v;
		FlxG.save.flush();
		return v;
	}

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
	public function load():Void {
		if (Reflect.hasField(FlxG.save.data, "inventories")) {
			var inventoryData:Array<Inventory.InventoryItem> = Reflect.field(FlxG.save.data.inventories, "day"+day);

			for (item in inventoryData) {
				inventory.addItem(item);
				if (item.DestroyParent) {
					var actor = ActorFactory.GetInstance().getActor(item.ActorID);
					if (actor != null) {
						actor.destroy();
					}
				}
			}
		}
	}

	public function save():Void {
		if (!Reflect.hasField(FlxG.save.data, "inventories")){
			FlxG.save.data.inventories = {};
		}

		Reflect.setField(Reflect.field(FlxG.save.data, "inventories"), "day"+day, inventory.getAllItems());

		FlxG.save.flush();
	}

	public function getCurrentDayName():String {
		return "default";
	}

	public function clearData():Void {
		FlxG.save.erase();
		FlxG.save.flush();
		inventory.clear();
		day = -1;
	}
}