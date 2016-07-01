package;

import flixel.group.FlxSpriteGroup;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxG;
import openfl.Assets;
import haxe.Json;
import flixel.FlxSprite;
import flixel.tweens.FlxTween;
import flixel.math.FlxRandom;
import flixel.math.FlxPoint;

enum SceneDirection {
	FORWARD;
	BACKWARD;
	LEFT;
	RIGHT;
}

class SceneManager extends FlxTypedGroup<FlxSpriteGroup> {
	
	static var instance:SceneManager;

	public static function GetInstance():SceneManager {
		if (instance != null) {
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

	private function new():Void {
		if (SceneManager.instance == null) {
			super();
			scenes = new Map<String, FlxSpriteGroup>();
			SceneManager.instance = this;
		}
	}

	public function addScene(Name:String, Scene:FlxSpriteGroup):Void {
		if (scenes.exists(Name)) {
			FlxG.log.error("Scene " + Name + " already exists in the scene manager.");
		} else {
			scenes.set(Name, Scene);
		}
	}

	public function getScene(Name:String):FlxSpriteGroup {
		if (scenes.exists(Name)) {
			return scenes.get(Name);
		}

		FlxG.log.error("Scene " + Name + " does not exist.");

		return null;
	}

	public function changeScene(Name:String, ?Direction:SceneDirection=null):Void {
		if (Direction == null) {
			Direction = RIGHT;
		}
		if (nextScene == null && !changingScenes) {
			//FlxG.log.add("Changing Scenes");
			nextScene = getScene(Name);
			if (nextScene != null) {
				changingScenes = true;
				if (currentScene != null) {
					var coords = getDirectionCoords(getOpositeDirection(Direction));
					FlxTween.tween(currentScene, { x: coords.x , y: coords.y}, .25);
				}

				var coords = getDirectionCoords(Direction);
				nextScene.x = coords.x;
				nextScene.y = coords.y;
				FlxTween.tween(nextScene, { x: 0 , y: 0 }, .35, { onComplete: sceneChanged }).start;
			} else {
				FlxG.log.error("Unable to set " + Name + " as current scene.");
			}
		} else {
			FlxG.log.error("Can't change scnese while scenes are changing.");
		}
	}

	private function sceneChanged(t:FlxTween):Void {
		changingScenes = false;
		currentScene = nextScene;
		nextScene = null;
	}

	public function loadScenes(JSONDataPath:String):Void {
		haxe.Log.trace("Scene file path " + JSONDataPath);
		var jsData = Json.parse(Assets.getText(JSONDataPath));
		var scenesData:Array<Dynamic> = Reflect.field(jsData, "scenes");
		for (scene in scenesData) {
			var newScene = parseScene(Reflect.field(scene, "data"));
			scenes.set(Reflect.field(scene, "name"), newScene);
			add(newScene);
			if (currentScene != null) {
				//currentScene.alpha = 0;
				currentScene.setPosition(-FlxG.width, -FlxG.height);
			}
			currentScene = newScene;
		}
	}

	private function parseScene(JSONDataPath:String):FlxSpriteGroup {
		var jsData = Json.parse(Assets.getText(JSONDataPath));
		var backgroundPath = Reflect.field(jsData, "background");
		var newScene = new FlxSpriteGroup();
		newScene.add(new FlxSprite(0, 0, backgroundPath));

		var actorsData:Array<Dynamic> = Reflect.field(jsData, "actors");
		for (actorData in actorsData) {
			ActorFactory.GetInstance().createActor(actorData).addToState(newScene);
		}

		return newScene;
	}

	public function getActorsInScene(?sceneName:String=null):Array<Actor> {
		var actors = new Array<Actor>();
		var scene = currentScene;
		if (sceneName != null && scenes.exists(sceneName)) {
			scene = scenes.get(sceneName);
		}

		for (actor in scene) {
			if (Std.is(actor, Actor)) {
				actors.push(cast(actor, Actor));
			}
		}

		return actors;
	}

	public function clearScenes():Void {
		for (sceneKey in scenes.keys()) {
			scenes.get(sceneKey).destroy();
			scenes.remove(sceneKey);
		}

		instance = null;
	}

	public function getOpositeDirection(direction:SceneDirection):SceneDirection {
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

	public function directionStringToType(directionName:String):SceneDirection {
		directionName = directionName.toUpperCase();
		if (directionName == "FORWARD") {
			return FORWARD;
		} else if (directionName == "BACKWARD") {
			return BACKWARD;
		} else if (directionName == "RIGHT") {
			return RIGHT;
		} else if (directionName == "LEFT") {
			return LEFT;
		}

		return null;
	}

	private function getDirectionCoords(direction:SceneDirection):FlxPoint {
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