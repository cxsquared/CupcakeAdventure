package managers;

import flixel.group.FlxSpriteGroup;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxG;
import openfl.Assets;
import haxe.Json;
import flixel.FlxSprite;
import flixel.tweens.FlxTween;
import flixel.math.FlxPoint;
import actors.*;

enum SceneDirection
{
    FORWARD;
    BACKWARD;
    LEFT;
    RIGHT;
}

typedef SceneChangeEvent = {Name:String, Direction:SceneDirection};

class SceneManager extends FlxTypedGroup<FlxSpriteGroup>
{

    static var instance:SceneManager;

    public static function GetInstance():SceneManager
    {
        if (instance != null)
        {
            return SceneManager.instance;
        }

        var sm = new SceneManager();
        SceneManager.instance = sm;
        return instance;
    }


    public var changingScenes:Bool = false;
    var scenes:Map<String, FlxSpriteGroup>;
    var currentScene:FlxSpriteGroup;
    var nextScene:FlxSpriteGroup;
    var sceneQueue:Array<SceneChangeEvent>;

    private function new():Void
    {
        if (SceneManager.instance == null)
        {
            super();
            scenes = new Map<String, FlxSpriteGroup>();
            sceneQueue = new Array<SceneChangeEvent>();
            SceneManager.instance = this;
        }
    }

    public function addScene(Name:String, Scene:FlxSpriteGroup):Void
    {
        if (scenes.exists(Name))
        {
            FlxG.log.error("Scene " + Name + " already exists in the scene manager.");
        }
        else
        {
            scenes.set(Name, Scene);
        }
    }

    public function getScene(Name:String):FlxSpriteGroup
    {
        if (scenes.exists(Name))
        {
            return scenes.get(Name);
        }

        FlxG.log.error("Scene " + Name + " does not exist.");

        return null;
    }

    public function getCurrentScene():String
    {
        for (sceneName in scenes.keys())
        {
            if (currentScene == scenes.get(sceneName))
            {
                return sceneName;
            }
        }

        return "";
    }

    override public function update(elapsed:Float):Void
    {
        if (sceneQueue.length > 0 && !changingScenes)
        {
            var nextSceneQueue = sceneQueue.shift();
            executeChangeScene(nextSceneQueue.Name, nextSceneQueue.Direction);
        }
        super.update(elapsed);
    }

    public function changeScene(SceneName:String, EnterDirection:SceneDirection = null):Void
    {
        var newSceneQueue = { Name:SceneName, Direction:EnterDirection};
        sceneQueue.push(newSceneQueue);
    }

    private function executeChangeScene(Name:String, Direction:SceneDirection = null):Void
    {
        // TODO: Make transitions fancier possibly with FlxTransition
        if (Direction == null)
        {
            Direction = RIGHT;
        }
        if (nextScene == null && !changingScenes)
        {
            nextScene = getScene(Name);
            if (nextScene != null)
            {
                changingScenes = true;
                if (currentScene != null)
                {
                    var coords = getDirectionCoords(getOpositeDirection(Direction));
                    FlxTween.tween(currentScene, { x: coords.x, y: coords.y}, .25);
                }

                var coords = getDirectionCoords(Direction);
                nextScene.x = coords.x;
                nextScene.y = coords.y;
                FlxTween.tween(nextScene, { x: 0, y: 0 }, .35, { onComplete: sceneChanged }).start;
                for (actor in getActorsInScene())
                {
                    actor.onExit();
                }
                for (actor in getActorsInScene(Name))
                {
                    actor.onEnter();
                }
            }
            else
            {
                FlxG.log.error("Unable to set " + Name + " as current scene.");
            }
        }
        else
        {
            FlxG.log.error("Can't change scnese while scenes are changing.");
        }
    }

    private function sceneChanged(t:FlxTween):Void
    {
        changingScenes = false;
        currentScene = nextScene;
        nextScene = null;
    }

    public function loadScenes(JSONDataPath:String, StartingScene:String):Void
    {
        ActorFactory.GetInstance().resetActorID();
        haxe.Log.trace("Scene file path " + JSONDataPath);
        var jsData = Json.parse(Assets.getText(JSONDataPath));
        var scenesData:Array<Dynamic> = Reflect.field(jsData, "scenes");
        for (scene in scenesData)
        {
            var newScene = parseScene(Reflect.field(scene, "data"));
            var sceneName = Reflect.field(scene, "name");
            scenes.set(sceneName, newScene);
            add(newScene);
            if (sceneName != StartingScene)
            {
                newScene.setPosition(-FlxG.width, -FlxG.height);
            }
            else
            {
                currentScene = newScene;
                currentScene.setPosition(0, 0);
            }
        }
        for (actor in getActorsInScene())
        {
            actor.onEnter();
        }

    }

    private function parseScene(JSONDataPath:String):FlxSpriteGroup
    {
        haxe.Log.trace("Parseing " + JSONDataPath);
        var jsData = Json.parse(Assets.getText(JSONDataPath));
        var backgroundPath = Reflect.field(jsData, "background");
        var newScene = new FlxSpriteGroup();
        newScene.add(new FlxSprite(0, 0, backgroundPath));

        var actorsData:Array<Dynamic> = Reflect.field(jsData, "actors");
        for (actorData in actorsData)
        {
            ActorFactory.GetInstance().createActor(actorData).addToState(newScene);
        }

        return newScene;
    }

    public function getActorsInScene(sceneName:String = null):Array<Actor>
    {
        var actors = new Array<Actor>();
        var scene = currentScene;
        if (sceneName != null && scenes.exists(sceneName))
        {
            scene = scenes.get(sceneName);
        }

        for (actor in scene)
        {
            if (Std.is(actor, Actor))
            {
                actors.push(cast(actor, Actor));
            }
        }

        return actors;
    }

    public function clearScenes():Void
    {
        for (sceneKey in scenes.keys())
        {
            scenes.get(sceneKey).destroy();
            scenes.remove(sceneKey);
        }

        instance = null;
    }

    public function getOpositeDirection(direction:SceneDirection):SceneDirection
    {
        switch (direction) {
            case FORWARD:
                return BACKWARD;
            case BACKWARD:
                return FORWARD;
            case RIGHT:
                return LEFT;
            case LEFT:
                return RIGHT;
        }

        return null;
    }

    public function directionStringToType(directionName:String):SceneDirection
    {
        directionName = directionName.toUpperCase();
        if (directionName == "FORWARD")
        {
            return FORWARD;
        }
        else if (directionName == "BACKWARD")
        {
            return BACKWARD;
        }
        else if (directionName == "RIGHT")
        {
            return RIGHT;
        }
        else if (directionName == "LEFT")
        {
            return LEFT;
        }

        return null;
    }

    private function getDirectionCoords(direction:SceneDirection):FlxPoint
    {
        var coords = new FlxPoint();

        switch (direction) {
            case FORWARD:
                coords.x = 0;
                coords.y = -FlxG.height;
            case BACKWARD:
                coords.x = 0;
                coords.y = FlxG.height;
            case RIGHT:
                coords.x = FlxG.width;
                coords.y = 0;
            case LEFT:
                coords.x = -FlxG.width;
                coords.y = 0;
        }

        return coords;
    }
}