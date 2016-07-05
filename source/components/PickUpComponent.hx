package components;

import flixel.FlxG;
import flixel.FlxSprite;

class PickUpComponent extends InteractableComponent {

	var description:String;
	var iconPath:String;
	var perminant:Bool = false;

	override public function init(Data:Dynamic):Bool {
		super.init(Data);

		description = Reflect.field(Data, "description");
		iconPath = Reflect.field(Data, "iconPath");
		var perm = Reflect.hasField(Data, "perminant");
		if (perm) {
			perminant = Reflect.field(Data, "perminant");
		}

		return true;
	}

	override public function postInit(){
		super.postInit();
	}

	override public function update(DeltaTime:Float) {
		super.update(DeltaTime);
	}

	override public function getComponentID():ActorComponentTypes {
		return ActorComponentTypes.PICKUP;
	}

	override private function onInteract():Void {
		if (perminant) {
			if (GameData.getInstance().inventory.getItem(owner.name) != null) {
				var textComp = cast(owner.getComponent(ActorComponentTypes.DESCRIPTION), DescriptionComponent);
				if (textComp == null) {
					var tempComp:DescriptionComponent = Type.createInstance(DescriptionComponent, []);
					tempComp.init({
						"description": "description",
						"color": {
							"r": FlxG.random.color().red,
							"g": FlxG.random.color().green,
							"b": FlxG.random.color().blue
						}
					});
					textComp = cast(owner.addComponent(tempComp), DescriptionComponent);
					textComp.postInit();
				}

				textComp = cast(textComp, DescriptionComponent);
				textComp.say("I don't need two of them.");
			}
			GameData.getInstance().inventory.addNewItem(owner.name, description, owner.getID(), iconPath);
			if(owner.animation.getByName("used") != null) {
				owner.animation.play("used");
			}
		} else {
			GameData.getInstance().inventory.addNewItem(owner.name, description, owner.getID(), iconPath);
			owner.kill();
		}
	}
}