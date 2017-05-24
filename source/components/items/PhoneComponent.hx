package components.items;

import managers.SoundManager;
import managers.GameData;

class PhoneComponent extends SceneChangeComponent
{

    var messageWaiting = true;

    override public function init(Data:Dynamic):Bool
    {
        super.init(Data);

        hideInventory = true;

        return true;
    }

    override public function postInit():Void
    {
        super.postInit();
        var hasListend = GameData.getInstance().getData(GameData.day, "phoneListened");
        if (!hasListend)
        {
            owner.animation.play("phoneAlert");
            SoundManager.GetInstance().playSound("phoneAlert", owner.x, owner.y);
        }
    }

    override public function getComponentID():ActorComponentTypes
    {
        return ActorComponentTypes.PHONE;
    }

    override private function onInteract():Void
    {
        messageWaiting = false;
        owner.animation.play("phoneIdle");
        SoundManager.GetInstance().stopSound("phoneAlert");
        super.onInteract();
        GameData.getInstance().saveData(GameData.day, "phoneListened", true);
    }
}