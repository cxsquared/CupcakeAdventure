package;

import haxe.Json;
import flixel.FlxG;
import components.*;
import flash.utils.Object;

class ActorFactory {
	private var lastActorId:Int;

	private var actorComponentCreators:Map<String, Class<Dynamic>>;

	public var actors:Map<Int, Actor>;

	public function new() {
		createComponentMap();
		actors = new Map<Int, Actor>();
	}

	private function createComponentMap():Void {
		actorComponentCreators = new Map<String, Class<ActorComponent>>();
		actorComponentCreators.set("PickUpComponent", PickUpComponent);
		actorComponentCreators.set("AnimationComponent", AnimationComponent);
		actorComponentCreators.set("CabinetComponent", CabinetComponent);
		actorComponentCreators.set("SceneChangeComponent", SceneChangeComponent);
		actorComponentCreators.set("HighlightComponent", HighlightComponent);
		actorComponentCreators.set("DescriptionComponent", DescriptionComponent);
	}

	public function createActor(Data:Dynamic):Actor {
		var actor:Actor = new Actor();
		FlxG.log.add("Creating new actor");

		if (actor.init(getNextActorId())) {
			// Location
			var x = Std.parseInt(Reflect.field(Data, "x"));
			if (x >= 0) {
				actor.x = x;
			}

			var y = Std.parseInt(Reflect.field(Data, "y"));
			if (y >= 0) {
				actor.y = y;
			}

			// Image
			var graphicFile = Reflect.field(Data, "spriteSheet");
			if (graphicFile != "" && graphicFile != null) {
				var width = Std.parseInt(Reflect.field(Data, "width"));
				var height = Std.parseInt(Reflect.field(Data, "height"));
				if (width > 0 && height > 0) {
					actor.loadGraphic(graphicFile, true, width, height);
				} else {
					actor.loadGraphic(graphicFile);
				}
			}

			// Components
			var componentsData:Array<Dynamic> = Reflect.field(Data, "components");
			for (component in componentsData) {
				var newComponent:ActorComponent = createComponent(component);

				if (newComponent != null) {
					actor.addComponent(newComponent);
				} else {
					FlxG.log.error("New Component " + Reflect.field(component, "name") + " failed to create on actor " + actor.getID());
				}
			}

			actor.postInit();
			actor.name = Reflect.field(Data, "name");

			actors.set(actor.getID(), actor);

			return actor;
		} else {
			FlxG.log.error("Actor " + actor.getID() + " failed to initialize.");
		}

		return null;
	}

	private function createComponent(Data:Dynamic):ActorComponent {
		//FlxG.log.add(Data);
		FlxG.log.add("Creating new component " + Reflect.field(Data, "name"));
		if (actorComponentCreators.exists(Reflect.field(Data, "name"))) {
			var newComponent:ActorComponent = Type.createInstance(actorComponentCreators[Reflect.field(Data, "name")], []);
			var componentData:String = Std.string(Reflect.field(Data, "data"));
			//FlxG.log.add("Data should be sent like " + componentData);
			if (newComponent.init(Reflect.field(Data, "data"))) {
				return newComponent;
			} else {
				FlxG.log.error("Component " + Reflect.field(Data, "name") + " failed to initialize.");
			}
		} else {
			FlxG.log.error("Component " + Reflect.field(Data, "name") + " doesn't exist in the component map.");
		}

		return null;
	}

	private function getNextActorId():Int {
		++lastActorId;
		return lastActorId;		
	}

	public function getActor(ID:Int):Actor {
		if (actors.exists(ID)) {
			return actors.get(ID);
		}

		return null;
	}
}