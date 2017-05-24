package managers;

import flixel.FlxG;
import inventory.*;
import actors.*;
import states.PlayState;
import openfl.Assets;
import haxe.Json;
import util.ObjectUtil;
import components.ActorComponentTypes;
import components.matchthree.MatchThreeTimerComponent;
import flixel.FlxObject;

enum TimeActions
{
    MIX;
    PICKUP;
}

class GameData
{

    private static var instance:GameData;
    public var heldItem:InventorySprite;
    public var inventory:Inventory;
    public var player:FlxObject;
    var timer:Actor;
    var dayoutcomesPath = "assets/data/dayoutcomes.json";
    var dayoutcomesData:Dynamic;

    var mixTime = 2.66;
    var itemTime = .14;
    var startTime = 8;

    @:isVar
    public var currentDay(get, null):String = "";

    private function get_currentDay():String
    {
        if (currentDay == "")
        {
            var possibleName = getData(day, "name");
            if (possibleName == null)
            {
                currentDay = getCurrentDayName();
                FlxG.log.add("Getting current day name " + currentDay);
                saveData(day, "name", currentDay);
            }
            else
            {
                currentDay = possibleName;
            }
        }

        return currentDay;
    }

    @:isVar
    public static var day(default, set):Int = -1;

    private static function set_day(v:Int):Int
    {
        GameData.getInstance().currentDay = "";
        day = FlxG.save.data.day = v;
        FlxG.save.flush();
        return day;
    }

    public static function getInstance():GameData
    {
        if (instance != null)
        {
            return instance;
        }

        var gd = new GameData();
        instance = gd;

        return instance;
    }

    @:isVar
    public var time(default, set):Float = -1;

    private function set_time(v:Float):Float
    {
        time = v;
        saveData(day, "time", v);
        return time;
    }

    private function new():Void
    {
        if (!FlxG.save.bind("CupcakeData"))
        {
            FlxG.log.error("Save failed to create!");
        }

        player = new FlxObject(FlxG.width / 2 - 25, FlxG.height / 2 - 25, 50, 50);

        ObjectUtil.getInstance().printObject(FlxG.save.data);

        inventory = new Inventory();

        dayoutcomesData = Json.parse(Assets.getText(dayoutcomesPath));
    }

    public function resetTime(isNewDay:Bool):Void
    {
        if (isNewDay)
        {
            this.time = startTime;
        }
        else
        {
            this.time = getData(day, "time");
        }

        FlxG.watch.add(this, "time", "Time left");
        timer = ActorFactory.GetInstance().createActor({
            "name": "timer",
            "x": 270,
            "y": -5,
            "width": -1,
            "height": -1,
            "spriteSheet": "assets/images/match/match_TimerBackground.png",
            "components": [
                {
                    "name": "MatchThreeTimerComponent",
                    "data": {
                        "time": startTime
                    }
                }
            ]
        });
        timer.scale.x = timer.scale.y = .5;
        timer.x = 270;
        timer.y = -5;
        timer.addToState(FlxG.state);
        var timerComp = cast(timer.getComponent(ActorComponentTypes.MATCHTIMER), MatchThreeTimerComponent);
        timerComp.time = startTime - time;
    }

    public function removeTime(timeType:TimeActions):Float
    {
        switch (timeType) {
            case TimeActions.MIX:
                time -= mixTime;
            case TimeActions.PICKUP:
                time -= itemTime;
                if (time <= 0)
                {
                    GameData.day++;
                    GameData.getInstance().inventory.clear();
                    GameData.getInstance().saveInventory();
                    FlxG.switchState(new PlayState());
                }
        }

        time = Math.max(time, 0);

        var timerComp = cast(timer.getComponent(ActorComponentTypes.MATCHTIMER), MatchThreeTimerComponent);
        timerComp.time = startTime - time;

        return time;
    }

    // This must be done after actors and scenes have been loaded
    public function loadInventory():Void
    {
        var tempInv:Array<Inventory.InventoryItem> = getData(day, "inventory");
        if (tempInv != null)
        {
            for (item in tempInv)
            {
                inventory.addItem(item);
                if (!item.DestroyParent)
                {
                    var actor = ActorFactory.GetInstance().getActor(item.ActorID);
                    if (actor != null)
                    {
                        actor.destroy();
                    }
                }
            }
        }
    }

    public function saveInventory():Void
    {
        saveData(day, "inventory", inventory.getAllItems());
    }

    private function getCurrentDayName():String
    {
        if (day == 1)
        {
            FlxG.log.add("Returning day 1 name");
            return "StartingOut";
        }
        else if (wasCupcakeMade(day - 1))
        {
            return getDayOutcome();
        }
        FlxG.log.add("Looking for no cupcake in " + getData(day - 1, "name"));
        return Reflect.field(Reflect.field(dayoutcomesData, getData(day - 1, "name")), "nocupcake");
    }

    private function getDayOutcome():String
    {
        var dayName = getData(day - 1, "name");
        FlxG.log.add("Looking for outcome from " + dayName);
        var possibleOutcomes = Reflect.field(dayoutcomesData, dayName);
        var tags:Array<String> = getData(day - 1, "cupcake");
        for (tag in tags)
        {
            if (Reflect.hasField(possibleOutcomes, tag))
            {
                return Reflect.field(possibleOutcomes, tag);
            }
        }

        return Reflect.field(possibleOutcomes, "anycupcake");
    }

    private function wasCupcakeMade(day:Int):Bool
    {
        var possibleCupcake = getData(day, "cupcake");
        return possibleCupcake != null;
    }

    public function saveCupcake(tags:Array<String>):Void
    {
        saveData(day, "cupcake", tags);
    }

    public function saveData(Day:Int, Field:String, Data:Dynamic):Void
    {
        FlxG.log.add("Saving " + Field);
        if (!Reflect.hasField(FlxG.save.data, "day" + Day))
        {
            Reflect.setField(FlxG.save.data, "day" + Day, {});
        }

        var tempData = Reflect.field(FlxG.save.data, "day" + Day);
        Reflect.setField(tempData, Field, Data);
        Reflect.setField(FlxG.save.data, "day" + Day, tempData);
        if (!FlxG.save.flush())
        {
            FlxG.log.error("Saving failed");
        }
    }

    public function getData(Day:Int, Field:String):Dynamic
    {
        FlxG.log.add("Getting " + Field);
        ObjectUtil.getInstance().printObject(FlxG.save.data);
        if (!Reflect.hasField(FlxG.save.data, "day" + Day))
        {
            return null;
        }

        var dayData = Reflect.field(FlxG.save.data, "day" + Day);
        if (Reflect.hasField(dayData, Field))
        {
            return Reflect.field(dayData, Field);
        }

        return null;
    }

    public function clearData():Void
    {
        FlxG.save.erase();
        FlxG.log.add("Clearing Data");
        if (!FlxG.save.bind("CupcakeData"))
        {
            FlxG.log.error("Save failed to create!");
        }
        day = 1;
    }
}