package components.matchthree;

import flixel.FlxG;
import flixel.ui.FlxBar;
import flixel.ui.FlxBar.FlxBarFillDirection;
import actors.Actor;

class MatchThreeMeterComponent implements ActorComponent {

	public var owner:Actor;

	private var meter:FlxBar;

	public var score:Float = 0;
	private var maxScore:Float;
	
	public function init(Data:Dynamic):Bool {
		var width = Reflect.field(Data, "width");
		var height = Reflect.field(Data, "height");
		maxScore = Reflect.field(Data, "maxScore");
		var background = Reflect.field(Data, "background");
		var fill = Reflect.field(Data, "fill");
		meter = new FlxBar(0, 0, FlxBarFillDirection.BOTTOM_TO_TOP, width, height, this, "score", 0, maxScore);
		meter.createImageBar(background, fill);
		return true;
	}

	public function postInit(){
		meter.x = owner.x;
		meter.y = owner.y;
		owner.visible = false;
	}

	public function update(DeltaTime:Float) {
	}

	public function getComponentID():ActorComponentTypes {
		return ActorComponentTypes.MATCHMETER;
	}

	public function onAdd(Owner:Dynamic):Void {
		Owner.add(meter);
	}
	
	public function destroy():Void {
		meter.destroy();
	}

	private function onInteract() {
	}

	public function onMouseEvent(e:MOUSEEVENT):Void{}

	public function onEnter():Void{
	}

	public function onExit():Void {
	}
	
}