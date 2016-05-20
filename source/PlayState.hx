package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.math.FlxMath;
import Actor;
import openfl.Assets;
import haxe.Json;

class PlayState extends FlxState
{
	var actorFactory:ActorFactory;
	var sceneManager:SceneManager;

	override public function create():Void
	{
		super.create();

		actorFactory = new ActorFactory();
		sceneManager = SceneManager.getInstance();

		sceneManager.loadScenes(AssetPaths.sceneData__json, actorFactory);
		sceneManager.changeScene("CabinetFridge");

		add(sceneManager);
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
	}
}
