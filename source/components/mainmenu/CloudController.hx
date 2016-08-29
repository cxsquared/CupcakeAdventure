package components.mainmenu;

import components.ActorComponent;
import flixel.group.FlxGroup;
import actors.Actor;
import actors.ActorFactory;

class CloudController implements ActorComponent {
	public var owner:Actor;

	var clouds:FlxGroup;
	
	public function init(Data:Dynamic):Bool {
		clouds = new FlxGroup();

		var cloudsData:Array<Dynamic> = Reflect.field(Data, "clouds");

		for (cloud in cloudsData) {
			var newCloud = ActorFactory.GetInstance().createActor({
				"name": "cloud",
				"x": -100,
				"y": -100,
				"width": -1,
				"height": -1,
				"spriteSheet": Reflect.field(cloud, "image"),
				"components": [
					{
						"name": "CloudComponent",
						"data": {
						}
					}
				]
			});

			clouds.add(newCloud);
		}

		return true;
	}

	public function postInit():Void {
	}

	public function update(DeltaTime:Float):Void {
	}

	public function getComponentID():ActorComponentTypes {
		return CLOUD;
	}

	public function onAdd(Owner:Dynamic):Void {
		for (cloud in clouds.members){
			Owner.add(cloud);
		}
	}

	public function onMouseEvent(e:MOUSEEVENT):Void {

	}

	public function onEnter():Void {

	}

	public function onExit():Void {

	}

	public function destroy():Void {
		//clouds.destroy();
	}
}