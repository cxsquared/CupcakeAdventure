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

		//FlxG.switchState(new MatchThreeState(["flour", "sugar", "butter", "milk", "salt"], 120, 5000));
		FlxG.switchState(new PlayState());
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
	}
}
