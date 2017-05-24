package states;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;
import actors.*;
import managers.SceneManager;
import flixel.tweens.FlxTween;
import managers.GameData;
import util.ObjectUtil;
import managers.SoundManager;

class MenuState extends FlxState
{
    var fadeout:FlxSprite;
    var fadingOut:Bool = false;
    var startingNewGame:Bool = false;

    override public function create():Void
    {
        super.create();

        SoundManager.GetInstance().loadSounds("assets/data/sounds/menuSounds.json");

        SoundManager.GetInstance().playMusic("MenuMusic");

        var actorFactory = ActorFactory.GetInstance();

        var sceneManager = SceneManager.GetInstance();
        sceneManager.clearScenes();

        sceneManager.loadScenes(AssetPaths.menuSceneData__json, "MainMenu");

        add(sceneManager);

        var newButton = new FlxButton(FlxG.width / 2, FlxG.height / 2, "New Game", newGame);
        newButton.x -= newButton.width / 2;
        newButton.y -= newButton.height;
        add(newButton);

        GameData.getInstance(); // Just to initalize save
        if (Reflect.hasField(FlxG.save.data, "day"))
        {
            var continueButton = new FlxButton(FlxG.width / 2, FlxG.height / 2, "Continue", continueGame);
            continueButton.x -= continueButton.width / 2;
            continueButton.y += continueButton.height;
            add(continueButton);
            GameData.day = FlxG.save.data.day;
        }

        fadeout = new FlxSprite();
        fadeout.makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
        fadeout.alpha = 0;

        ObjectUtil.getInstance().printObject(FlxG.save.data);
    }

    private function newGame():Void
    {
        GameData.getInstance().clearData();
        GameData.day = 1;
        startingNewGame = true;
        continueGame();
    }

    private function continueGame():Void
    {
        add(fadeout);
        FlxTween.tween(fadeout, {alpha:1}, .5, {onComplete:startGame});
        fadingOut = true;
    }

    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);
    }

    private function startGame(t:FlxTween):Void
    {
        if (startingNewGame)
        {
            FlxG.switchState(new PlayState());
        }
        else
        {
            FlxG.switchState(new PlayState("Bookshelf", false));
        }
    }

    override public function destroy():Void
    {
        SceneManager.GetInstance().clearScenes();
        //TODO: Destroy ui
        super.destroy();
    }
}
