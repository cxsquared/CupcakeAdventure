package components;

import managers.GameData;
import managers.GameData.TimeActions;
import components.AnimationComponent;

class PickUpComponent extends InteractableComponent
{

    var description:String;
    var iconPath:String;
    var perminant:Bool = false;
    var name:String = "";
    var animationContoller:AnimationComponent;

    override public function init(Data:Dynamic):Bool
    {
        super.init(Data);

        description = Reflect.field(Data, "description");
        iconPath = Reflect.field(Data, "iconPath");
        var perm = Reflect.hasField(Data, "perminant");
        if (perm)
        {
            perminant = Reflect.field(Data, "perminant");
        }

        if (Reflect.hasField(Data, "name"))
        {
            name = Reflect.field(Data, "name");
        }

        return true;
    }

    override public function postInit()
    {
        super.postInit();

        if (name == "")
        {
            name = owner.name;
        }

        if (owner.hasComponent(ActorComponentTypes.ANIMATION))
        {
            animationContoller = cast(owner.getComponent(ActorComponentTypes.ANIMATION), AnimationComponent);
        }
    }

    override public function update(DeltaTime:Float)
    {
        super.update(DeltaTime);
    }

    override public function getComponentID():ActorComponentTypes
    {
        return ActorComponentTypes.PICKUP;
    }

    override private function onInteract():Void
    {
        if (perminant)
        {
            var itemCheck = GameData.getInstance().inventory.getItem(name);
            if (itemCheck != null)
            {
                owner.getTextComponent().say("I don't need two of them.");
                GameData.getInstance().inventory.addItem(itemCheck);
            }
            else
            {
                GameData.getInstance().inventory.addNewItem(name, description, owner.getID(), iconPath, perminant);
                if (owner.animation.getByName("used") != null)
                {
                    animationContoller.ChangeAnimation("used");
                }
            }
        }
        else
        {
            GameData.getInstance().inventory.addNewItem(name, description, owner.getID(), iconPath, perminant);
            owner.kill();
        }
        GameData.getInstance().removeTime(TimeActions.PICKUP);
    }
}