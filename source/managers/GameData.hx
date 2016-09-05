package managers;

import flixel.FlxG;
import inventory.*;
import actors.*;
import states.PlayState;
import openfl.Assets;
import haxe.Json;
import util.ObjectUtil;

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
			var possibleName = getData(day, "name");
			if (possibleName == null){
				currentDay = getCurrentDayName();
				saveData(day, "name", currentDay);
			} else {
				currentDay = possibleName;
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

		return instance;
	}

	private function new():Void {
		if (!FlxG.save.bind("CupcakeData")) {
			FlxG.log.error("Save failed to create!");
		}

		ObjectUtil.getInstance().printObject(FlxG.save.data);

		inventory = new Inventory();

		dayoutcomesData = Json.parse(Assets.getText(dayoutcomesPath));
	}

	// This must be done after actors and scenes have been loaded
	public function loadInventory():Void {
		var tempInv:Array<Inventory.InventoryItem> = getData(day, "inventory");
		if (tempInv != null) {
			//TODO: Check if this is working
			for (item in tempInv) {
				inventory.addItem(item);
				if (!item.DestroyParent) {
					var actor = ActorFactory.GetInstance().getActor(item.ActorID);
					if (actor != null) {
						actor.destroy();
					}
				}
			}
		}
	}

	public function saveInventory():Void {
		saveData(day, "inventory", inventory.getAllItems());
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
		var dayName = getData(day-1, "name");
		var possibleOutcomes = Reflect.field(dayoutcomesData, dayName);
		var tags:Array<String> = getData(day-1, "cupcake");
		for (tag in tags) {
			if (Reflect.hasField(possibleOutcomes, tag)) {
				return Reflect.field(possibleOutcomes, tag);
			}
		}

		return Reflect.field(possibleOutcomes, "anycupcake");
	}

	private function wasCupcakeMade(day:Int):Bool {
		var possibleCupcake = getData(day, "cupcake");
		return possibleCupcake != null;
	}

	public function saveCupcake(tags:Array<String>):Void {
		saveData(day, "cupcake", tags);
	}

	public function saveData(Day:Int, Field:String, Data:Dynamic):Void {
		FlxG.log.add("Saving " + Field);
		if (!Reflect.hasField(FlxG.save.data, "day"+Day)) {
			Reflect.setField(FlxG.save.data, "day"+Day, {});
		}

		var tempData = Reflect.field(FlxG.save.data, "day"+Day);
		Reflect.setField(tempData, Field, Data);
		Reflect.setField(FlxG.save.data, "day"+Day, tempData);
		if (!FlxG.save.flush()) {
			FlxG.log.error("Saving failed");
		}

		ObjectUtil.getInstance().printObject(FlxG.save.data);
	}

	public function getData(Day:Int, Field:String):Dynamic {
		FlxG.log.add("Getting " + Field);
		ObjectUtil.getInstance().printObject(FlxG.save.data);
		if (!Reflect.hasField(FlxG.save.data, "day"+Day)) {
			return null;
		}

		var dayData = Reflect.field(FlxG.save.data, "day"+Day);
		if (Reflect.hasField(dayData, Field)) {
			return Reflect.field(dayData, Field);
		}

		return null;
	}

	public function clearData():Void {
		FlxG.save.erase();
		FlxG.save.flush();
		inventory.clear();
		day = -1;
		FlxG.log.add("Clearing Data");
	}
}