package components;

import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.FlxG;

class DescriptionComponent extends InteractableComponent
{
    var text:FlxText;
    var description:String;
    var viewLength:Float = 2.5;

    var viewTimer:FlxTimer;

    override public function init(Data:Dynamic):Bool
    {
        super.init(Data);

        description = Reflect.field(Data, "description");

        if (Reflect.hasField(Data, "viewLength"))
        {
            viewLength = Reflect.field(Data, "viewLength");
        }

        text = new FlxText();
        text.text = description;
        text.alpha = 0;
        text.setFormat(text.font, 10, text.color);
        text.setBorderStyle(OUTLINE, FlxColor.BLACK, 1);

        if (Reflect.hasField(Data, "color"))
        {
            var color = Reflect.field(Data, "color");
            text.color = FlxColor.fromRGB(Reflect.field(color, "r"), Reflect.field(color, "g"), Reflect.field(color, "b"), 0);
        }

        viewTimer = new FlxTimer();

        return true;
    }

    override public function postInit()
    {
        super.postInit();
    }

    override public function update(DeltaTime:Float)
    {
        super.update(DeltaTime);

        text.x = owner.x + owner.width / 2 - text.width / 2;
        text.y = owner.y - text.height - 10;

        if (text.x + text.width > FlxG.width)
        {
            text.x = FlxG.width - text.width;
        }
        else if (text.x < 0)
        {
            text.x = 0;
        }

        if (text.y < 0)
        {
            text.y = 0;
        }
        else if (text.y + text.height > FlxG.height)
        {
            text.y = FlxG.height - text.height;
        }

        if (!owner.alive && !viewTimer.active)
        {
            text.alpha = 0;
            text.kill();
        }
    }

    override public function getComponentID():ActorComponentTypes
    {
        return ActorComponentTypes.DESCRIPTION;
    }

    override private function onInteract():Void
    {
        text.text = description;
        showText();
        viewTimer.start(viewLength, textTimerComplete, 1);
    }

    private function textTimerComplete(t:FlxTimer):Void
    {
        text.alpha = 0;
        text.text = description;
    }

    override public function onAdd(Owner:Dynamic)
    {
        Owner.add(text);
    }

    public function say(textToSay, time:Float = 2.5)
    {
        text.text = textToSay;

        if (text.alpha == 0)
        {
            showText();
            viewTimer.start(time, textTimerComplete, 1);
        }
        else
        {
            viewTimer.reset(time);
        }
    }

    private function showText():Void
    {
        text.alpha = 1;
        FlxG.state.members.remove(text);
        FlxG.state.add(text);
    }

    override public function onExit():Void
    {
        text.alpha = 0;
    }

    public function isTalking():Bool
    {
        return text.alpha > .5;
    }
}