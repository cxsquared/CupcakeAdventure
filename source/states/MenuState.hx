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
import actors.*;
import managers.SceneManager;
import flixel.util.FlxColor;
import flixel.tweens.FlxTween;

class MenuState extends FlxState
{
	var fadeout:FlxSprite;
	var fadingOut:Bool = false;

	override public function create():Void
	{
		super.create();

		var actorFactory = ActorFactory.GetInstance();

		var sceneManager = SceneManager.GetInstance();
		sceneManager.clearScenes();

		sceneManager.loadScenes(AssetPaths.menuSceneData__json);
		sceneManager.changeScene("MainMenu");

		add(sceneManager);

		fadeout = new FlxSprite();
		fadeout.makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		fadeout.alpha = 0;
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);

		if (FlxG.mouse.justPressed && !fadingOut) {
			add(fadeout);
			FlxTween.tween(fadeout, {alpha:1}, .5, {onComplete:startGame});
			fadingOut = true;
		}
	}

	private function startGame(t:FlxTween):Void {
		FlxG.switchState(new PlayState());
		//FlxG.switchState(new MatchThreeState(["flour", "sugar", "butter", "milk", "salt", "carmel"], 120, 750));
		//FlxG.switchState(new IcingGameState(null, FlxColor.CYAN));
	}

	override public function destroy():Void {
		SceneManager.GetInstance().clearScenes();
		//TODO: Destroy ui
		super.destroy();
	}
}
