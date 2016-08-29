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

class PlayState extends FlxState
{
	var actorFactory:ActorFactory;
	var sceneManager:SceneManager;
	public var inventoryUI:InventoryUI;

	override public function create():Void
	{
		super.create();

		actorFactory = ActorFactory.GetInstance();

		SceneManager.GetInstance().clearScenes();
		sceneManager = SceneManager.GetInstance();

		sceneManager.loadScenes(AssetPaths.sceneData__json);
		sceneManager.changeScene("Kitchen");

		add(sceneManager);

		inventoryUI = new InventoryUI();
		add(inventoryUI);
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
