package components;

import managers.GameData;
import components.AnimationComponent;

class OneTimeUseComponent extends InteractableComponent
{

    var persistent:Bool = false;
    var animation:String = "";
    var hasPlayed:Bool = false;
    var animationController:AnimationComponent;

    override public function init(Data:Dynamic):Bool
    {
        persistent = Reflect.field(Data, "persistent");
        animation = Reflect.field(Data, "animation");
        return super.init(Data);
    }

    override public function postInit()
    {
        if (persistent)
        {
            var isUsed = GameData.getInstance().getData(-1, owner.name + "hasPlayed");
            if (isUsed)
            {
                hasPlayed = true;
                if (hasPlayed)
                {
                    owner.animation.play(animation, true, false);
                }
            }
        }

        animationController = cast(owner.getComponent(ActorComponentTypes.ANIMATION), AnimationComponent);
    }

    override public function getComponentID():ActorComponentTypes
    {
        return ActorComponentTypes.ONETIMEUSE;
    }

    override private function onInteract():Void
    {
        if (!hasPlayed)
        {
            animationController.ChangeAnimation(animation);
            hasPlayed = true;
            if (persistent)
            {
                GameData.getInstance().saveData(-1, owner.name + "hasPlayed", true);
            }
        }
    }

}