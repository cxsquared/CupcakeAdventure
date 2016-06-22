package;

import flixel.FlxSprite;
import flixel.FlxG;
import components.*;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.FlxState;

class Actor extends FlxSprite {
	
	private var actorComponents:Map<ActorComponentTypes, ActorComponent>;

	private var actorID:Int;

	public var name:String;

	override public function new(?X:Float = 0, ?Y:Float = 0, ?SimpleGraphic:FlxGraphicAsset) {
		super(X, Y, SimpleGraphic);

		actorComponents = new Map<ActorComponentTypes, ActorComponent>();
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
		super.update(elapsed);
		//FlxG.log.add("Updating actor " + actorID);
		// Update Components
		for (component in actorComponents) {
			component.update(elapsed);
			//FlxG.log.add("Updating component " + component.getComponentID() + " on actor " + actorID);
		}
	}

	public function addComponent(ActorComponent:ActorComponent) {
		//FlxG.log.add("Adding component " + ActorComponent.getComponentID() + " on actor " + actorID);
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

	public function getComponent(ComponentID:ActorComponentTypes):ActorComponent {
		if (actorComponents.exists(ComponentID)){
			return actorComponents.get(ComponentID);
		}

		FlxG.log.warn("Couldn't find actor component " + ComponentID + " on actor " + actorID);

		return null;
	}

	public function addToState(Owner:Dynamic) {
		Owner.add(this);

		for (component in actorComponents) {
			component.onAdd(Owner);
		}
	}

	override public function destroy():Void {
		for (component in actorComponents) {
			component.destroy();
		}

		super.destroy();
	}
}