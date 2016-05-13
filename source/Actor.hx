package;

import flixel.FlxSprite;
import flixel.FlxG;
import components.*;
import flixel.system.FlxAssets.FlxGraphicAsset;

class Actor extends FlxSprite {
	
	private var actorComponents:Map<Int, ActorComponent>;

	private var actorID:Int;

	public var name:String;

	override public function new(?X:Float = 0, ?Y:Float = 0, ?SimpleGraphic:FlxGraphicAsset) {
		super(X, Y, SimpleGraphic);

		actorComponents = new Map<Int, ActorComponent>();
	}

	public function init(ID:Int):Bool {
		actorID = ID;

		return true;
	}

	public function postInit() {
		// Initialize Components
		for (component in actorComponents) {
			component.postInit();
		}
	}

	override public function update(elapsed:Float) {
		//FlxG.log.add("Updating actor " + actorID);
		// Update Components
		for (component in actorComponents) {
			component.update(elapsed);
			//FlxG.log.add("Updating component " + component.getComponentID() + " on actor " + actorID);
		}
		super.update(elapsed);
	}

	public function addComponent(ActorComponent:ActorComponent) {
		FlxG.log.add("Adding component " + ActorComponent.getComponentID() + " on actor " + actorID);
		if (!actorComponents.exists(ActorComponent.getComponentID())){
			actorComponents.set(ActorComponent.getComponentID(), ActorComponent);
			ActorComponent.owner = this;
		} else {
			FlxG.log.warn("Component " + ActorComponent.getComponentID() + " already exists on actor " + actorID);
		}
	}

	public function getID():Int {
		return actorID;
	}

	public function getComponent(ComponentID:Int):ActorComponent {
		if (actorComponents.exists(ComponentID)){
			return actorComponents.get(ComponentID);
		}

		FlxG.log.warn("Couldn't find actor component " + ComponentID + " on actor " + actorID);

		return null;
	}
}