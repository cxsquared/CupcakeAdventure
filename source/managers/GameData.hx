package managers;

import flixel.FlxG;
import inventory.*;
import actors.*;
import states.PlayState;
import openfl.Assets;
import haxe.Json;

class GameData {
	
	private static var instance:GameData;
	public var heldItem:InventorySprite;
	public var inventory:Inventory;
	var dayoutcomesPath = "assets/data/dayoutcomes.json";
	var dayoutcomesData:Dynamic;

	@:isVar
	public var currentDay(get, null):String = "";
	private function get_currentDay():String {
		if (currentDay == "") {
			if (Reflect.hasField(FlxG.save.data, "dayNames")) {
				if (Reflect.hasField(FlxG.save.data.dayNames, "day" + day)) {
					currentDay = Reflect.field(FlxG.save.data.dayNames, "day" + day);
				} else {
					currentDay = getCurrentDayName();
					Reflect.setField(FlxG.save.data.dayNames, "day"+day, currentDay);
					FlxG.save.flush();
				}
			} else {
				FlxG.save.data.dayNames = {};
				currentDay = getCurrentDayName();
				Reflect.setField(FlxG.save.data.dayNames, "day"+day, currentDay);
				FlxG.save.flush();
			}
		}

		return currentDay;
	}

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

		dayoutcomesData = Json.parse(Assets.getText(dayoutcomesPath));
	}

	// This must be done after actors and scenes have been loaded
	public function load():Void {
		if (Reflect.hasField(FlxG.save.data, "inventories")) {
			var inventoryData:Array<Inventory.InventoryItem> = Reflect.field(FlxG.save.data.inventories, "day"+day);

			//TODO: Check if this is working
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
		if (day == 1) {
			return "StartingOut";
		} else if (wasCupcakeMade(day-1)) {
			return getDayOutcome();
		}

		return Reflect.field(Reflect.field(dayoutcomesData, currentDay), "nocupcake");
	}

	private function getDayOutcome():String {
		var possibleOutcomes = Reflect.field(dayoutcomesData, Reflect.field(FlxG.save.data.dayNames, "day"+(day-1)));
		var tags:Array<String> = Reflect.field(FlxG.save.data.cupcakes, "day"+day);
		for (tag in tags) {
			if (Reflect.hasField(possibleOutcomes, tag)) {
				return Reflect.field(possibleOutcomes, tag);
			}
		}

		return Reflect.field(possibleOutcomes, "anycupcake");
	}

	private function wasCupcakeMade(day:Int):Bool {
		return Reflect.hasField(FlxG.save.data, "cupcakes") && Reflect.hasField(Reflect.field(FlxG.save.data, "cupcakes"), "day"+day);
	}

	public function saveCupcake(tags:Array<String>):Void {
		if (!Reflect.hasField(FlxG.save.data, "cupcakes")) {
			FlxG.save.data.cupcakes = {};
		}

		Reflect.setField(FlxG.save.data.cupcakes, "day"+day, tags);
		FlxG.save.flush();
	}

	public function clearData():Void {
		FlxG.save.erase();
		FlxG.save.flush();
		inventory.clear();
		day = -1;
	}
}