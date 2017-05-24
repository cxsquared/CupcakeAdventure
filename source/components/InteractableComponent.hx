package components;

import flixel.FlxG;
import actors.Actor;

class InteractableComponent implements ActorComponent
{

    public var owner:Actor;

    public function init(Data:Dynamic):Bool
    {
        return true;
    }

    public function postInit()
    {
    }

    public function update(DeltaTime:Float)
    {
    }

    public function getComponentID():ActorComponentTypes
    {
        FlxG.log.error("Invalid interactable Component");
        return ActorComponentTypes.INVALID; // This number should never be refferenced
    }

    public function onAdd(Owner:Dynamic):Void
    {
    }

    public function onMouseEvent(e:MOUSEEVENT):Void
    {
        if (e == MOUSEEVENT.DOWN)
        {
            onInteract();
        }
    }

    public function destroy():Void
    {
    }

    private function onInteract():Void
    {
    }

    public function onEnter():Void
    {
    }

    public function onExit():Void
    {
    }
}