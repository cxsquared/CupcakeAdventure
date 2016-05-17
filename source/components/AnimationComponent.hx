package components;

import flixel.FlxG;

class AnimationComponent implements ActorComponent {

	public var owner:Actor;
	private var animationData:Map<String, Array<Int>>;
	private var frameRate:Int;
	
	public function init(Data:Dynamic):Bool {
		FlxG.log.add("Creating a new Animation Component with Data: " + Std.string(Reflect.fields(Data)));
		var animations:Array<Dynamic> = Reflect.field(Data, "animations");
		FlxG.log.add(animations);
		if (animations != null && animations.length > 0) {
			for (animation in animations) {
				animationData.set(Reflect.field(animation, "name"), Reflect.field(animation, "frames"));
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
			owner.animation.add(animation, animationData.get(animation));
		}
	}

	public function update(DeltaTime:Float) {
	}

	public function getComponentID():Int {
		return 2;
	}

	public function ChangeAnimation(Name:String, Reversed:Bool=false) {
		if (animationData.exists(Name)) {
			owner.animation.play(Name, Reversed);
		} else {
			FlxG.log.error("Animation " + Name + " doesn't exists in animaiton component on " + owner.getID());
		}
	}
	
}