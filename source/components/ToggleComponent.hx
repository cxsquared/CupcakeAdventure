package components;

import managers.GameData;
import components.AnimationComponent;

class ToggleComponent extends InteractableComponent
{
    var persistent:Bool = false;
    var animation:String = "";
    var altAnimation:String = "";
    var hasPlayed:Bool = false;
    var animationController:AnimationComponent;

    override public function init(Data:Dynamic):Bool
    {
        persistent = Reflect.field(Data, "persistent");
        animation = Reflect.field(Data, "animation");
        if (Reflect.hasField(Data, "altAnimation"))
        {
            altAnimation = Reflect.field(Data, "altAnimation");
        }
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
        return ActorComponentTypes.TOGGLE;
    }

    override private function onInteract():Void
    {
        if (hasPlayed)
        {
            if (altAnimation != "")
            {
                animationController.ChangeAnimation(altAnimation);
            }
            else
            {
                animationController.ChangeAnimation(animation, true);
            }
        }
        else
        {
            animationController.ChangeAnimation(animation);
        }
        hasPlayed = !hasPlayed;
        if (persistent)
        {
            GameData.getInstance().saveData(-1, owner.name + "hasPlayed", hasPlayed);
        }
    }

}