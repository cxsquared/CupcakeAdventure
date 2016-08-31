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
		if (day == -1) {
			if (!Reflect.hasField(FlxG.save.data, "day")) {
				FlxG.save.data.day = 1;
				FlxG.log.add("Initializing day");
				FlxG.save.flush();
			} else {
				day = FlxG.save.data.day;
			}
		}

		return day;
	}
	private static function set_day(v:Int):Int {
		FlxG.save.data.day = v;
		day = v;
		FlxG.save.flush();
		return day;
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
	public function load(af:ActorFactory):Void {
		var inventoryData:Array<Inventory.InventoryItem> = FlxG.save.data.inventory;

		for (item in inventoryData) {
			inventory.addItem(item);
			af.getActor(item.ActorID).destroy();
		}
	}

	public function save():Void {
		FlxG.save.data.inventory = inventory.getAllItems();
		FlxG.save.data.flush();
	}

	public function getCurrentDayName():String {
		return "default";
	}
}