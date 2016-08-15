package components;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxMath;
import actors.Actor;

class MatchThreeTimerComponent implements ActorComponent {

	public var owner:Actor;

	private var arrow:FlxSprite;
	public var time:Float;
	private var maxTime:Float;

	private var rotations = 64;

	public function init(Data:Dynamic):Bool {
		time = 0;
		maxTime = Reflect.field(Data, "time");

		arrow = new FlxSprite();
		arrow.loadRotatedGraphic(AssetPaths.match_TimerArrow__png, rotations);

		return true;
	}

	public function postInit():Void{
		arrow.x = owner.x;
		arrow.y = owner.y;
	}

	public function update(DeltaTime:Float):Void{
		arrow.angle = FlxMath.lerp(0, 360, Math.min(time/maxTime, 1));
	}

	public function getComponentID():ActorComponentTypes{
		return ActorComponentTypes.MATCHTIMER;
	}

	public function onAdd(Owner:Dynamic):Void{
		Owner.add(arrow);
	}

	public function destroy():Void{
		arrow.destroy();
	}

	public function onMouseEvent(e:MOUSEEVENT):Void{}

	public function onEnter():Void{
	}

	public function onExit():Void {
	}
	
}