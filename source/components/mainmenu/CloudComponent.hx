package components.mainmenu;

import components.ActorComponent;
import actors.Actor;
import flixel.util.FlxTimer;
import flixel.FlxG;

class CloudComponent implements ActorComponent
{
    public var owner:Actor;

    var minWidth = 1.5;
    var maxWidth = .75;
    var minHeight = 1.25;
    var maxHeight = .75;

    var minY = -10;
    var maxY = 50;

    var cloudTimer:FlxTimer;
    var minRepeat = .5;
    var maxRepeat = 2;
    var minSpeed = 7.5;
    var maxSpeed = 30;

    public function init(Data:Dynamic):Bool
    {
        cloudTimer = new FlxTimer();

        if (Reflect.hasField(Data, "minWidth"))
        {
            minWidth = Reflect.field(Data, "minWidth");
        }
        if (Reflect.hasField(Data, "maxWidth"))
        {
            maxWidth = Reflect.field(Data, "maxWidth");
        }
        if (Reflect.hasField(Data, "minHeight"))
        {
            minHeight = Reflect.field(Data, "minHeight");
        }
        if (Reflect.hasField(Data, "maxHeight"))
        {
            maxHeight = Reflect.field(Data, "maxHeight");
        }
        if (Reflect.hasField(Data, "minY"))
        {
            minY = Reflect.field(Data, "minY");
        }
        if (Reflect.hasField(Data, "maxY"))
        {
            maxY = Reflect.field(Data, "maxY");
        }
        if (Reflect.hasField(Data, "minRepeat"))
        {
            minRepeat = Reflect.field(Data, "minRepeat");
        }
        if (Reflect.hasField(Data, "maxRepeat"))
        {
            maxRepeat = Reflect.field(Data, "maxRepeat");
        }
        if (Reflect.hasField(Data, "minSpeed"))
        {
            minSpeed = Reflect.field(Data, "minSpeed");
        }
        if (Reflect.hasField(Data, "maxSpeed"))
        {
            maxSpeed = Reflect.field(Data, "maxSpeed");
        }

        return true;
    }

    public function postInit():Void
    {
        if (FlxG.random.bool(25))
        {
            startCloud();
            owner.x = FlxG.random.float(0, FlxG.width * .75);
        }
        else
        {
            owner.x = -owner.width * 2;
            cloudTimer.start(FlxG.random.float(minRepeat, maxRepeat), startCloud, 1);
        }
    }

    public function update(DeltaTime:Float):Void
    {
        if (!cloudTimer.active && owner.x > FlxG.width + owner.width)
        {
            cloudTimer.start(FlxG.random.float(minRepeat, maxRepeat), startCloud, 1);
        }
    }

    private function startCloud(t:FlxTimer = null):Void
    {
        owner.x = -owner.width * 2;
        owner.scale.x = FlxG.random.float(minWidth, maxWidth) * FlxG.random.sign();
        owner.scale.y = FlxG.random.float(minHeight, maxHeight);

        owner.y = FlxG.random.float(minY, maxY);
        owner.velocity.x = FlxG.random.float(minSpeed, maxSpeed);
    }

    public function getComponentID():ActorComponentTypes
    {
        return CLOUDCONTROLLER;
    }

    public function onAdd(Owner:Dynamic):Void
    {
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
        cloudTimer.destroy();
    }

}