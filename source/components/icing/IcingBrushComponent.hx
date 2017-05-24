package components.icing;

import actors.Actor.MOUSEEVENT;
import actors.Actor;
import flixel.FlxG;
import flixel.util.FlxColor;
import flixel.group.FlxSpriteGroup;
import flixel.FlxSprite;

class IcingBrushComponent implements ActorComponent
{
    public var owner:Actor;

    private var brushStrokes:FlxSpriteGroup;

    var icingColor:FlxColor;
    var minRadius = .5;
    var maxRadius = 1;
    var minCheck = 1;

    public var icingLevels = [25, 50, 75, 100];

    public var icingOutOfBounds = 0;

    public function init(Data:Dynamic):Bool
    {
        var color = Reflect.field(Data, "color");

        icingColor = FlxColor.fromRGB(Reflect.field(color, "r"), Reflect.field(color, "g"), Reflect.field(color, "b"));
        return true;
    }

    public function postInit():Void
    {
        brushStrokes = new FlxSpriteGroup();
    }

    public function update(DeltaTime:Float):Void
    {
        if (FlxG.mouse.pressed)
        {
            var size = FlxG.random.float(minRadius, maxRadius);
            var rect = new FlxSprite(FlxG.mouse.x - (minCheck / 2), FlxG.mouse.y - (minCheck / 2));
            rect.makeGraphic(Std.int(minCheck), Std.int(minCheck), FlxColor.PINK);
            if (!FlxG.overlap(brushStrokes, rect))
            {
                var stroke = new FlxSprite(0, 0, AssetPaths.icing__png);
                stroke.scale.x = stroke.scale.y = size;
                stroke.updateHitbox();
                stroke.x = FlxG.mouse.x - (stroke.width / 2);
                stroke.y = FlxG.mouse.y - (stroke.height / 2);
                stroke.color = icingColor;
                if (!FlxG.pixelPerfectOverlap(owner, rect))
                {
                    icingOutOfBounds++;
                    FlxG.watch.addQuick("Icing out of bounds", icingOutOfBounds);
                }
                brushStrokes.add(stroke);
            }
            rect.destroy();
        }
    }

    public function getComponentID():ActorComponentTypes
    {
        return ICINGBRUSH;
    }

    public function onAdd(Owner:Dynamic):Void
    {
        Owner.add(brushStrokes);
    }

    public function onMouseEvent(e:MOUSEEVENT):Void
    {

    }

    public function onEnter():Void
    {
    }

    public function onExit():Void
    {
    }

    public function destroy():Void
    {
        brushStrokes.destroy();
    }
}