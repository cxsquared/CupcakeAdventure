package components;

import actors.Actor.MOUSEEVENT;
import actors.Actor;
import flixel.util.FlxCollision;
import flixel.FlxG;
import flixel.util.FlxColor;
import flixel.group.FlxSpriteGroup;
import flixel.FlxSprite;
import flixel.math.FlxRect;
import flixel.FlxObject;

class IcingBrushComponent implements ActorComponent {
	public var owner:Actor;

	private var brushStrokes:FlxSpriteGroup;

	var icingColor:FlxColor;
	var minRadius = 5;
	var maxRadius = 20;

	public var icingOutOfBounds = 0;

	public function init(Data:Dynamic):Bool {
		var color = Reflect.field(Data, "color");

		icingColor = FlxColor.fromRGB(Reflect.field(color, "r"), Reflect.field(color, "g"), Reflect.field(color, "b"));
		return true;
	}

	public function postInit():Void {
		brushStrokes = new FlxSpriteGroup();
	}

	public function update(DeltaTime:Float):Void {
		if (FlxG.mouse.pressed) {
			var size = FlxG.random.float(minRadius, maxRadius);
			var rect = new FlxSprite(FlxG.mouse.x-(minRadius/4), FlxG.mouse.y - (minRadius/4));
			rect.makeGraphic(Std.int(minRadius/2), Std.int(minRadius/2), FlxColor.PINK);
			if (!FlxG.overlap(brushStrokes, rect)) {
				var stroke = new FlxSprite(FlxG.mouse.x - (size/2), FlxG.mouse.y - (size/2));
				stroke.makeGraphic(Std.int(size), Std.int(size), icingColor);
				if (!FlxG.pixelPerfectOverlap(owner, rect)) {
					icingOutOfBounds++;
					FlxG.watch.addQuick("Icing out of bounds", icingOutOfBounds);
				}
				brushStrokes.add(stroke);
			}
			rect.destroy();
		}
	}

	public function getComponentID():ActorComponentTypes {
		return ICINGBRUSH;
	}

	public function onAdd(Owner:Dynamic):Void {
		Owner.add(brushStrokes);
	}

	public function onMouseEvent(e:MOUSEEVENT):Void {
		
	}

	public function onEnter():Void {
	}

	public function onExit():Void {
	}

	public function destroy():Void {
		brushStrokes.destroy();
	}
}