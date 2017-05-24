package components.items;

import flixel.FlxG;
import actors.Actor;
import managers.SceneManager;
import managers.SoundManager;

//TODO: Make it where you can't leave scene if it's open

class FridgeComponent extends InteractableComponent
{

    var topOpen:Bool = false;
    var bottomOpen:Bool = false;

    var doorCutOff = 81;

    var topNotes:Array<Actor>;
    var bottomNotes:Array<Actor>;

    override public function init(Data:Dynamic):Bool
    {
        super.init(Data);
        return true;
    }

    override public function postInit()
    {
        super.postInit();
        owner.animation.callback = onAnim;
    }

    override public function update(DeltaTime:Float)
    {
        super.update(DeltaTime);
    }

    override public function getComponentID():ActorComponentTypes
    {
        return ActorComponentTypes.FRIDGE;
    }

    override private function onInteract():Void
    {
        if (FlxG.mouse.y < owner.y + doorCutOff)
        {
            topClicked();
        }
        else
        {
            bottomClicked();
        }
    }

    private function topClicked():Void
    {
        if (topOpen)
        {
            topOpen = false;
            SoundManager.GetInstance().playSound("closeCabinet", owner.x, owner.y);
            if (bottomOpen)
            {
                owner.animation.play("topAfterBottom", false, true);
            }
            else
            {
                owner.animation.play("topOnly", false, true);
            }
        }
        else
        {
            SoundManager.GetInstance().playSound("openCabinet", owner.x, owner.y);
            topOpen = true;
            if (bottomOpen)
            {
                owner.animation.play("topAfterBottom", false);
                updateNotes(false, false);
            }
            else
            {
                owner.animation.play("topOnly", false);
                updateNotes(false, true);
            }
        }
    }

    private function bottomClicked():Void
    {
        if (bottomOpen)
        {
            bottomOpen = false;
            SoundManager.GetInstance().playSound("closeCabinet", owner.x, owner.y);
            if (topOpen)
            {
                owner.animation.play("bottomAfterTop", false, true);
            }
            else
            {
                owner.animation.play("bottomOnly", false, true);
            }
        }
        else
        {
            bottomOpen = true;
            SoundManager.GetInstance().playSound("openCabinet", owner.x, owner.y);
            if (topOpen)
            {
                owner.animation.play("bottomAfterTop", false);
                updateNotes(false, false);
            }
            else
            {
                owner.animation.play("bottomOnly", false);
                updateNotes(true, false);
            }
        }
    }

    private function updateNotes(showTop:Bool, showBottom:Bool):Void
    {
        findNotes();

        FlxG.watch.addQuick("TopNotes", topNotes);
        FlxG.watch.addQuick("BottomNotes", bottomNotes);

        for (note in topNotes)
        {
            note.alpha = showTop ? 1 : 0;
        }

        for (note in bottomNotes)
        {
            note.alpha = showBottom ? 1 : 0;
        }
    }

    private function findNotes():Void
    {
        if (topNotes == null || bottomNotes == null)
        {
            topNotes = new Array<Actor>();
            bottomNotes = new Array<Actor>();
            var actors = SceneManager.GetInstance().getActorsInScene();

            for (actor in actors)
            {
                if (actor.hasComponent(ActorComponentTypes.LETTER) && FlxG.overlap(actor, owner))
                {
                    if (actor.y < owner.y + doorCutOff)
                    {
                        topNotes.push(actor);
                    }
                    else
                    {
                        bottomNotes.push(actor);
                    }
                }
            }
        }
    }

    private function onAnim(name:String, num:Int, index:Int):Void
    {
        if (name == "topAfterBottom" && num == 0 && !topOpen)
        {
            updateNotes(true, false);
        }
        else if (name == "topOnly" && num == 0 && !topOpen)
        {
            updateNotes(true, true);
        }
        else if (name == "bottomAfterTop" && num == 0 && !bottomOpen)
        {
            updateNotes(false, true);
        }
        else if (name == "bottomOnly" && num == 0 && !bottomOpen)
        {
            updateNotes(true, true);
        }
    }

    override public function onExit():Void
    {
    }

    override public function onEnter():Void
    {
    }
}