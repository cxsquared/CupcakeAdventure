package states;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.math.FlxMath;
import actors.*;
import openfl.Assets;
import haxe.Json;
import managers.SceneManager;
import inventory.*;
import managers.GameData;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.text.FlxText;
import flixel.util.FlxTimer;

class PlayState extends FlxState
{
	var actorFactory:ActorFactory;
	var sceneManager:SceneManager;
	public var inventoryUI:InventoryUI;

	var fade:FlxSprite;
	var fadingout:Bool = false;
	var fadingin:Bool = false;

	var dayText:FlxText;
	var dayTextTimer:FlxTimer;

	var startingRoom = "Bookshelf";
	var newDay = true;

	public function new (StartingRoom:String="Bookshelf", NewDay:Bool=true):Void {
		super();
		startingRoom = StartingRoom;
		newDay = NewDay;
	}

	override public function create():Void
	{
		super.create();

		actorFactory = ActorFactory.GetInstance();

		SceneManager.GetInstance().clearScenes();
		sceneManager = SceneManager.GetInstance();

		sceneManager.loadScenes(AssetPaths.sceneData__json, startingRoom);
		//sceneManager.changeScene(startingRoom, true);

		add(sceneManager);

		inventoryUI = new InventoryUI();
		add(inventoryUI);

		fade = new FlxSprite();
		fade.makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		add(fade);

		if (newDay) {
			dayText = new FlxText(0, 0, FlxG.width/2, "Day " + GameData.day, 24);
			dayText.x = FlxG.width/2 - dayText.width/2;
			dayText.y = FlxG.height/2 - dayText.height/2;
			add(dayText);

			dayTextTimer = new FlxTimer();
			dayTextTimer.start(2, startDay, 1);
			GameData.getInstance().resetTime();
		} else {
			startDay(null);
		}

		GameData.getInstance().loadInventory();
	}

	private function startDay(t:FlxTimer):Void {
		FlxTween.tween(fade, {alpha:0}, 2, {onComplete:fadeDone});
		if (newDay) {
			FlxTween.tween(dayText, {alpha:0}, 1);
		}
		fadingin = true;
	}

	private function fadeDone(t:FlxTween):Void {
		if (fadingin) {
			remove(fade);
			fadingin = false;
		} else if (fadingout) {

		}
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);

		FlxG.watch.addQuick("Inventory", GameData.getInstance().inventory.getAllItems().length);
	}

	override public function destroy():Void {
		sceneManager.clearScenes();
		//TODO: Destroy ui
		super.destroy();
	}
}
