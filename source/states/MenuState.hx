package states;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.math.FlxMath;
import actors.Actor;
import openfl.Assets;
import haxe.Json;
import flixel.util.FlxColor;

class MenuState extends FlxState
{
	override public function create():Void
	{
		super.create();

		//FlxG.switchState(new MatchThreeState(["flour", "sugar", "butter", "milk", "salt", "carmel"], 120, 750));
		FlxG.switchState(new PlayState());
		//FlxG.switchState(new IcingGameState(null, FlxColor.CYAN));
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
	}
}
