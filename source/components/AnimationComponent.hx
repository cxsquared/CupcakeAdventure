package components;

import flixel.FlxG;
import actors.Actor;
import managers.SoundManager;

typedef AnimData =
{
    var frames:Array<Int>;
    var looped:Bool;
    var sounds:Array<String>;
}

class AnimationComponent implements ActorComponent
{
    public var owner:Actor;
    private var animationData:Map<String, AnimData>;
    private var frameRate:Int;

    public function init(Data:Dynamic):Bool
    {
        animationData = new Map<String, AnimData>();
        var animations:Array<Dynamic> = Reflect.field(Data, "animations");
        if (animations != null && animations.length > 0)
        {
            for (animation in animations)
            {
                var animData:AnimData = { frames:Reflect.field(animation, "frames"), looped: Reflect.field(animation, "looped"), sounds:Reflect.field(animation, "sounds")};
                animationData.set(Reflect.field(animation, "name"), animData);
            }
        }
        else
        {
            FlxG.log.error("No animations in data for component " + getComponentID());
            return false;
        }

        frameRate = Std.parseInt(Reflect.field(Data, "frameRate"));
        if (frameRate <= 0)
        {
            FlxG.log.error("Animation component needs a frameRate on actor " + owner.getID());
        }

        return true;
    }

    public function postInit()
    {
        for (animation in animationData.keys())
        {
            var animData = animationData.get(animation);
            owner.animation.add(animation, animData.frames, frameRate, animData.looped);
        }
    }

    public function update(DeltaTime:Float)
    {
    }

    public function getComponentID():ActorComponentTypes
    {
        return ActorComponentTypes.ANIMATION;
    }

    public function ChangeAnimation(Name:String, Reversed:Bool = false)
    {
        if (animationData.exists(Name))
        {
            owner.animation.play(Name, Reversed);
            if (animationData.get(Name).sounds.length > 0)
            {
                SoundManager.GetInstance().playSound(FlxG.random.getObject(animationData.get(Name).sounds));
            }
        }
        else
        {
            FlxG.log.error("Animation " + Name + " doesn't exists in animaiton component on " + owner.getID());
        }
    }

    public function onAdd(Owner:Dynamic):Void
    {
    }

    public function destroy():Void
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

}