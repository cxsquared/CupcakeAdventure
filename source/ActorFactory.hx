package;

import haxe.Json;
import flixel.FlxG;
import components.*;
import flash.utils.Object;

class ActorFactory {
	private var lastActorId:Int;

	private var actorComponentCreators:Map<String, Class<Dynamic>>;

	public function new() {
		actorComponentCreators = new Map<String, Class<ActorComponent>>();
		actorComponentCreators.set("PickUpComponent", PickUpComponent);
	}

	public function createActor(Data:Dynamic):Actor {
		var actor:Actor = new Actor();
		FlxG.log.add("Creating new actor");

		if (actor.init(getNextActorId())) {
			FlxG.log.add("Adding components " + Data);
			var componentsData:Array<Dynamic> = Reflect.field(Data, "components");
			for (component in componentsData) {
				FlxG.log.add("Adding new component");
				var newComponent:ActorComponent = createComponent(component);

				if (newComponent != null) {
					actor.addComponent(newComponent);
				} else {
					FlxG.log.error("New Component " + Reflect.field(component, "name") + " failed to create on actor " + actor.getID());
				}
			}

			actor.postInit();

			return actor;
		} else {
			FlxG.log.error("Actor " + actor.getID() + " failed to initialize.");
		}

		return null;
	}

	private function createComponent(Data:Dynamic):ActorComponent {
		FlxG.log.add(Data);
		FlxG.log.add("Creating new component " + Reflect.field(Data, "name"));
		if (actorComponentCreators.exists(Reflect.field(Data, "name"))) {
			var newComponent:ActorComponent = Type.createInstance(actorComponentCreators[Reflect.field(Data, "name")], []);

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
}