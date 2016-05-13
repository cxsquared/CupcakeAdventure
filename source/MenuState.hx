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

		haxe.Log.trace(Assets.getText(AssetPaths.testKitchen__json));

		var background = new FlxSprite(AssetPaths.kitchen_Background__png);
		add(background);
		var jsData = Json.parse(Assets.getText(AssetPaths.testKitchen__json));
		/*
		FlxG.log.add(Reflect.field(jsData, "actors"));
		var actorsData:Array<Dynamic> = Reflect.field(jsData, "actors");
		for (actor in actorsData) {
			FlxG.log.add(Reflect.field(actor, "name"));
		}
		FlxG.log.add(Reflect.fields(Reflect.field(jsData, "actors")).toString());
		*/
		var fridge:Actor = af.createActor(Reflect.field(jsData, "actors")[0]);
		fridge.loadGraphic(AssetPaths.kitchen_Fridge__png);

		add(fridge);

		var cabinet = new FlxSprite(AssetPaths.kitchen_Cabinet__png);
		add(cabinet);
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
	}
}
