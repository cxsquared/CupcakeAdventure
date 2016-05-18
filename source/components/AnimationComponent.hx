package components;

import flixel.FlxG;

typedef AnimData = { 
	var frames:Array<Int>; 
	var looped:Bool;
}

class AnimationComponent implements ActorComponent {

	public var owner:Actor;
	private var animationData:Map<String, AnimData>;
	private var frameRate:Int;
	
	public function init(Data:Dynamic):Bool {
		animationData = new Map<String, AnimData>();
		//FlxG.log.add("Creating a new Animation Component with Data: " + Std.string(Reflect.fields(Data)));
		var animations:Array<Dynamic> = Reflect.field(Data, "animations");
		//FlxG.log.add(animations);
		if (animations != null && animations.length > 0) {
			for (animation in animations) {
				var animData:AnimData = { frames:Reflect.field(animation, "frames"), looped: Reflect.field(animation, "looped")};
				animationData.set(Reflect.field(animation, "name"), animData);
			}
		} else {
			FlxG.log.error("No animations in data for component " + getComponentID());
			return false;
		}

		frameRate = Std.parseInt(Reflect.field(Data, "frameRate"));
		if (frameRate <= 0) {
			FlxG.log.error("Animation component needs a frameRate on actor " + owner.getID());
		}

		return true;
	}

	public function postInit(){
		for (animation in animationData.keys()) {
			var animData = animationData.get(animation);
			owner.animation.add(animation, animData.frames, frameRate, animData.looped);
		}
	}

	public function update(DeltaTime:Float) {
	}

	public function getComponentID():ActorComponentTypes {
		return ActorComponentTypes.ANIMATION;
	}

	public function ChangeAnimation(Name:String, Reversed:Bool=false) {
		if (animationData.exists(Name)) {
			owner.animation.play(Name, Reversed);
		} else {
			FlxG.log.error("Animation " + Name + " doesn't exists in animaiton component on " + owner.getID());
		}
	}
	
}