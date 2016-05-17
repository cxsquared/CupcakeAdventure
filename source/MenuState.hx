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

class MenuState extends FlxState
{
	override public function create():Void
	{
		super.create();

		var af = new ActorFactory();

		var background = new FlxSprite(AssetPaths.FridgeCabinet__png);
		add(background);

		var jsData = Json.parse(Assets.getText(AssetPaths.testCabinetFridge__json));
		var cabinet:Actor = af.createActor(Reflect.field(jsData, "actors")[0]);
		add(cabinet);

	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
	}
}
