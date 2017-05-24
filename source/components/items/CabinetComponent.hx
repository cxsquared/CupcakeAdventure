package components.items;

import flixel.FlxG;
import managers.SoundManager;
import managers.GameData;

class CabinetComponent extends InteractableComponent
{

    var leftOpen:Bool = false;
    var rightOpen:Bool = false;
    var offset:Int = 0;

    override public function init(Data:Dynamic):Bool
    {
        super.init(Data);

        if (Reflect.hasField(Data, "offset"))
        {
            offset = Reflect.field(Data, "offset");
        }

        return true;
    }

    override public function postInit()
    {
        super.postInit();

        if (GameData.getInstance().getData(GameData.day, Std.string(getComponentID()) + Std.string(owner.getID()) + "leftOpen") == true)
        {
            leftClicked(false);
        }
        if (GameData.getInstance().getData(GameData.day, Std.string(getComponentID()) + Std.string(owner.getID()) + "rightOpen") == true)
        {
            rightClicked(false);
        }
    }

    override public function update(DeltaTime:Float)
    {
        FlxG.watch.addQuick("left open", leftOpen);
        FlxG.watch.addQuick("right open", rightOpen);
        super.update(DeltaTime);
    }

    override public function getComponentID():ActorComponentTypes
    {
        return ActorComponentTypes.CABINET;
    }

    override private function onInteract():Void
    {
        if (FlxG.mouse.x < owner.x + owner.width / 2 + offset)
        {
            leftClicked();
        }
        else
        {
            rightClicked();
        }
    }

    private function rightClicked(sound:Bool = true):Void
    {
        if (rightOpen)
        {
            rightOpen = false;
            if (sound)
            {
                SoundManager.GetInstance().playSound("closeCabinet", owner.x, owner.y);
            }
            if (leftOpen)
            {
                owner.animation.play("rightAfterLeft", false, true);
            }
            else
            {
                owner.animation.play("justRightDoor", false, true);
            }
        }
        else
        {
            if (sound)
            {
                SoundManager.GetInstance().playSound("openCabinet", owner.x, owner.y);
            }
            rightOpen = true;
            if (leftOpen)
            {
                owner.animation.play("rightAfterLeft", false);
            }
            else
            {
                owner.animation.play("justRightDoor", false);
            }
        }
    }

    private function leftClicked(sound:Bool = true):Void
    {
        if (leftOpen)
        {
            leftOpen = false;
            if (sound)
            {
                SoundManager.GetInstance().playSound("closeCabinet", owner.x, owner.y);
            }
            if (rightOpen)
            {
                owner.animation.play("leftAfterRight", false, true);
            }
            else
            {
                owner.animation.play("justLeftDoor", false, true);
            }
        }
        else
        {
            leftOpen = true;
            if (sound)
            {
                SoundManager.GetInstance().playSound("openCabinet", owner.x, owner.y);
            }
            if (rightOpen)
            {
                owner.animation.play("leftAfterRight", false);
            }
            else
            {
                owner.animation.play("justLeftDoor", false);
            }
        }
    }

    override public function onEnter():Void
    {
    }

    override public function onExit():Void
    {
        saveDoors();
    }

    private function saveDoors():Void
    {
        GameData.getInstance().saveData(GameData.day, Std.string(getComponentID()) + Std.string(owner.getID()) + "leftOpen", leftOpen);
        GameData.getInstance().saveData(GameData.day, Std.string(getComponentID()) + Std.string(owner.getID()) + "rightOpen", rightOpen);
    }
}