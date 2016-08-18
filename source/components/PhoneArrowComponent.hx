package components;

import managers.SceneManager;
import actors.Actor;
import flixel.FlxG;

class PhoneArrowComponent extends InteractableComponent {

	private var manager:MessageComponent;
	private var next:Bool = true;

	override public function init(Data:Dynamic):Bool {
		super.init(Data);
		next = Reflect.field(Data, "isNext");
		return true;
	}

	override public function getComponentID():ActorComponentTypes {
		return ActorComponentTypes.PHONEARROW;
	}

	override private function onInteract():Void {
		if (next) {
			manager.nextMessage();
		} else {
			manager.previousMessage();
		}
	}

	override public function onEnter():Void {
		for (actor in SceneManager.GetInstance().getActorsInScene("Phone")) {
			FlxG.log.add("Looking at actor " + actor.getID());
			if (actor.hasComponent(ActorComponentTypes.MESSAGES)) {
				manager = cast(actor.getComponent(ActorComponentTypes.MESSAGES), MessageComponent);
				FlxG.log.add("found manager");
				break;
			}
		}
	}
	
}