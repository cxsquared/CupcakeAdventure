package;

import flixel.group.FlxSpriteGroup;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxG;
import openfl.Assets;
import haxe.Json;
import flixel.FlxSprite;

class SceneManager extends FlxTypedGroup<FlxSpriteGroup> {
	
	static var instance:SceneManager;

	public static function getInstance():SceneManager {
		if (instance != null) {
			return SceneManager.instance;
		}

		var sm = new SceneManager();
		SceneManager.instance = sm;
		return instance;
	}

	var scenes:Map<String, FlxSpriteGroup>;
	var currentScene:FlxSpriteGroup;

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

	public function changeScene(Name:String):Void {
		var nextScene = getScene(Name);
		if (nextScene != null) {
			if (currentScene != null) {
				currentScene.setPosition(-FlxG.width, -FlxG.height);
			}

			nextScene.setPosition(0, 0);
			currentScene = nextScene;
		} else {
			FlxG.log.error("Unable to set " + Name + " as current scene.");
		}
	}

	public function loadScenes(JSONDataPath:String, ActorFactory:ActorFactory):Void {
		haxe.Log.trace("Scene file path " + JSONDataPath);
		var jsData = Json.parse(Assets.getText(JSONDataPath));
		var scenesData:Array<Dynamic> = Reflect.field(jsData, "scenes");
		for (scene in scenesData) {
			var newScene = parseScene(Reflect.field(scene, "data"), ActorFactory);
			scenes.set(Reflect.field(scene, "name"), newScene);
			add(newScene);
			if (currentScene != null) {
				currentScene.setPosition(-FlxG.width, -FlxG.height);
			}
			currentScene = newScene;
		}
	}

	private function parseScene(JSONDataPath:String, ActorFactory:ActorFactory):FlxSpriteGroup {
		var jsData = Json.parse(Assets.getText(JSONDataPath));
		var backgroundPath = Reflect.field(jsData, "background");
		var newScene = new FlxSpriteGroup();
		newScene.add(new FlxSprite(0, 0, backgroundPath));

		var actorsData:Array<Dynamic> = Reflect.field(jsData, "actors");
		for (actorData in actorsData) {
			newScene.add(ActorFactory.createActor(actorData));
		}

		return newScene;
	}
}