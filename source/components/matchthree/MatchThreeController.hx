// MatchThreeController.hx -- Controls the match three mini-game itemsData and flow
package components.matchthree;

import flixel.FlxG;
import flixel.math.FlxPoint;
import flixel.math.FlxRandom;
import flixel.group.FlxGroup.FlxTypedGroup;
import actors.*;
import flixel.FlxSprite;
import flixel.util.FlxTimer;
import actors.Actor.MOUSEEVENT;
import states.PlayState;
import managers.GameData;
import managers.SoundManager;
import openfl.Assets;
import haxe.Json;

typedef MatchData = { type:MatchThreeItems, items:Array<FlxPoint> };

enum MatchThreeItems
{
    NONE;
    FLOUR;
    SUGAR;
    SALT;
    MILK;
    BUTTER;
    COCONUT;
    ALMOND;
    VANILLA;
    CHOCOLATE;
    CARMEL;
    PUMPKIN;
    SPICE;
    CARROT;
}

enum CupcakeQuality
{
    BAD;
    OKAY;
    GOOD;
    PERFECT;
}

typedef ItemChance = { chance:Int, repeat:Int, points:Int };

class MatchThreeController implements ActorComponent
{
    public var owner:Actor;

    private var itemChanceData:Map<MatchThreeItems, ItemChance>;
    private var itemRepeats:Map<MatchThreeItems, Int>;
    private var itemChanceJsonFile = "assets/data/matchthree/matchIngredients.json";

    private var resolvingMatches = false;
    private var shouldReslove = false;
    private var noMatch = false;
    private var score = 0;

    private var width = 5;
    private var height = 5;
    private var startingX = 86;
    private var startingY = 10;
    private var itemSize = 44;

    private var itemsData:Array<Array<MatchThreeItems>>; // [Column][Row]
    private var items:Array<FlxTypedGroup<FlxSprite>>;
    private var dyingItems:FlxTypedGroup<FlxSprite>;

    private var matches:Array<MatchData>;
    private var possibleItems:Array<MatchThreeItems>;
    private var numberOfMatches = 0;

    private var rand:FlxRandom;

    public var numberOfItemsWaiting = 0;
    public var numberOfItemsSwitching = 0;

    private var shouldSwitchCheck = false;

    private var lastSwitch:Array<FlxPoint>;

    private var meter:MatchThreeMeterComponent;
    private var meterX = 14;
    private var meterY = 7;
    private var maxScore = 1000;
    private var minScore = 0;

    private var noMatchTimer:FlxTimer;
    private var noMatchTime = 1;
    private var noMatchImage:FlxSprite;

    private var timerStartX = 0;
    private var timerSTartY = 178;
    private var matchMoves = 10;
    private var currentMove = 0;

    private var timerComponent:MatchThreeTimerComponent;

    private var cupcake:String;

    public function init(Data:Dynamic):Bool
    {
        currentMove = 0;
        itemsData = new Array<Array<MatchThreeItems>>();
        matches = new Array<MatchData>();
        rand = new FlxRandom();
        items = new Array<FlxTypedGroup<FlxSprite>>();
        lastSwitch = new Array<FlxPoint>();

        minScore = Reflect.field(Data, "minscore");
        maxScore = Reflect.field(Data, "maxscore");
        matchMoves = Reflect.field(Data, "moves");
        cupcake = Reflect.field(Data, "cupcake");

        FlxG.log.add("Match moves " + matchMoves);

        setUpMeter();

        setUpItems(Reflect.field(Data, "items"));

        setUpTimers();

        return true;
    }

    private function endLevel(t:FlxTimer):Void
    {
    }

    private function setUpMeter():Void
    {
        var meterActor = ActorFactory.GetInstance().createActor({
            "name": "meter",
            "x": 14,
            "y": 7,
            "width": -1,
            "height": -1,
            "spriteSheet": "",
            "components": [
                {
                    "name": "MatchThreeMeterComponent",
                    "data": {
                        "width": 38,
                        "height": 225,
                        "maxScore": maxScore,
                        "background": "assets/images/match/match_meterBackground.png",
                        "fill": "assets/images/match/match_meterFill.png"
                    }
                }
            ]
        });

        meter = cast(meterActor.getComponent(ActorComponentTypes.MATCHMETER), components.matchthree.MatchThreeMeterComponent);
    }

    private function setUpItems(items:Array<String> = null):Void
    {
        possibleItems = new Array<MatchThreeItems>();
        if (items == null)
        {
            possibleItems.push(FLOUR);
            possibleItems.push(SUGAR);
            possibleItems.push(SALT);
            possibleItems.push(MILK);
            possibleItems.push(BUTTER);
        }
        else
        {
            for (item in items)
            {
                possibleItems.push(MatchThreeController.itemTypeFromString(item));
            }
        }

        generateItemChance();
        generateBoard();
    }


    private function generateItemChance():Void
    {
        itemChanceData = new Map<MatchThreeItems, ItemChance>();
        itemRepeats = new Map<MatchThreeItems, Int>();

        var allItemData = Json.parse(Assets.getText(itemChanceJsonFile));

        for (item in possibleItems)
        {
            var itemData = Reflect.field(allItemData, item.getName().toLowerCase());
            var chanceData:ItemChance = { chance:Reflect.field(itemData, "chance"), repeat:Reflect.field(itemData, "repeat"), points:Reflect.field(itemData, "points")};
            itemChanceData.set(item, chanceData);
            itemRepeats.set(item, 0);
        }
    }

    private function setUpTimers():Void
    {
        var timerActor = ActorFactory.GetInstance().createActor({
            "name": "matchTimer",
            "x": timerStartX,
            "y": timerSTartY,
            "width": -1,
            "height": -1,
            "spriteSheet": "assets/images/match/match_TimerBackground.png",
            "components": [
                {
                    "name": "MatchThreeTimerComponent",
                    "data": {
                        "time": matchMoves
                    }
                }
            ]
        });

        timerComponent = cast(timerActor.getComponent(ActorComponentTypes.MATCHTIMER), MatchThreeTimerComponent);

        noMatchTimer = new FlxTimer();
        noMatchImage = new FlxSprite();
        noMatchImage.loadGraphic(AssetPaths.nomatch__png);
        noMatchImage.x = FlxG.width / 2 - noMatchImage.width / 2;
        noMatchImage.y = FlxG.height / 2 - noMatchImage.height / 2;
        noMatchImage.visible = false;
    }

    public function postInit():Void
    {
    }

    public function update(DeltaTime:Float):Void
    {
        #if !NO_FLX_DEBUG
        var rowCount = 0;
        for (row in itemsData)
        {
            FlxG.watch.addQuick("Item row " + rowCount, row);
            rowCount++;
        }

        FlxG.watch.addQuick("Score", score);

        FlxG.watch.addQuick("possible items", possibleItems);
        FlxG.watch.addQuick("Moves", currentMove);

        if (FlxG.keys.justPressed.R)
        {
            shuffleBoard();
        }

        #end


        if (shouldSwitchCheck && numberOfItemsSwitching <= 0 && numberOfItemsWaiting <= 0 && !noMatch)
        {
            if (!checkItems())
            {
                switchItems(lastSwitch[0], lastSwitch[1], false);
            }
            else
            {
                FlxG.log.add("current moves " + currentMove);
                currentMove++;
            }

            shouldSwitchCheck = false;
        }
        else if (shouldReslove && numberOfItemsWaiting <= 0 && numberOfItemsSwitching <= 0 && !noMatch)
        {
            resolveMatches();
        }
        else if (numberOfItemsWaiting <= 0 && numberOfItemsSwitching <= 0 && !shouldSwitchCheck && !shouldReslove && !noMatch)
        {
            if (!checkItems())
            {
                if (!canMatch())
                {
                    noMatch = true;
                    noMatchImage.visible = true;
                    noMatchTimer.start(noMatchTime, shuffleTimer, 1);
                }
            }
        }

        meter.score = this.score;
        timerComponent.time = currentMove;

        if (currentMove > matchMoves)
        {
            GameData.getInstance().saveData(GameData.day, "currentDough", cupcake);
            GameData.getInstance().saveData(GameData.day, "quality", getQuality().getName());
            //TODO: Make function to find dough icons by getting recipe data
            GameData.getInstance().loadInventory();
            GameData.getInstance().inventory.addNewItem(cupcake, "Some " + getQuality().getName().toLowerCase() + " " + cupcake + " dough.", -1, "assets/images/inventory/cupcakeDefaultInv.png", false);
            GameData.getInstance().saveInventory();
            FlxG.switchState(new PlayState("Kitchen", false));
        }
    }

    public function getComponentID():ActorComponentTypes
    {
        return ActorComponentTypes.MATCHTHREE;
    }

    public function onAdd(Owner:Dynamic):Void
    {
        for (row in items)
        {
            Owner.add(row);
        }

        meter.owner.addToState(Owner);
        timerComponent.owner.addToState(Owner);
        Owner.add(noMatchImage);
        dyingItems = new FlxTypedGroup<FlxSprite>();
        Owner.add(dyingItems);
    }

    public function destroy():Void
    {
        for (match in matches)
        {
            for (item in match.items)
            {
                var tempItem = item;
                match.items.remove(item);
                tempItem.destroy();
            }
        }
    }

    private function generateBoard():Void
    {
        for (y in 0...height)
        {
            var row = new Array<MatchThreeItems>();
            var itemRow = new FlxTypedGroup<FlxSprite>();
            for (x in 0...width)
            {
                var newItem = getRandomItem();
                row.push(newItem);
                var actor = createItem(x, y, newItem);
                var itComp = cast(actor.getComponent(ActorComponentTypes.MATCHTHREEITEM), MatchThreeItemComponent);
                itemRow.add(actor);
                itComp.drop(startingX + itComp.gridX * actor.width, (startingY + itComp.gridY * actor.height) - FlxG.height);
            }
            itemsData.push(row);
            items.push(itemRow);
        }
    }

    private function resolveMatches():Void
    {
        if (matches.length > 0 && !resolvingMatches)
        {
            shouldReslove = false;
            resolvingMatches = true;
            numberOfMatches = matches.length;
            var numberRemoved = 0;
            for (match in matches)
            {
                resloveMatch(match);
            }

            matches.splice(0, matches.length);

            numberOfMatches = matches.length;
            fillBoardHoles();
        }
    }

    private function resloveMatch(match:MatchData):Void
    {
        switch (match.type) {
            case SALT:
                lineResolve(match);
            case COCONUT:
                lineResolve(match);
            case ALMOND:
                lineResolve(match);
            case VANILLA:
                lineResolve(match);
            case CHOCOLATE:
                lineResolve(match);
            case CARMEL:
                lineResolve(match);
            case PUMPKIN:
                lineResolve(match);
            case SPICE:
                lineResolve(match);
            case CARROT:
                lineResolve(match);
            default:
                defaultReslove(match);
        }
    }

    private function defaultReslove(match:MatchData, checkType:Bool = true):Void
    {
        var multiplier = 1 + ((match.items.length - 3) / 4);
        for (item in match.items)
        {
            updateScore(itemsData[Math.floor(item.y)][Math.floor(item.x)], multiplier);
            if (checkType)
            {
                if (itemsData[Math.floor(item.y)][Math.floor(item.x)] == match.type)
                {
                    removeItemActor(Math.floor(item.x), Math.floor(item.y), itemsData[Math.floor(item.y)][Math.floor(item.x)]);
                    itemsData[Math.floor(item.y)][Math.floor(item.x)] = NONE;
                }
                else if (itemsData[Math.floor(item.y)][Math.floor(item.x)] != NONE)
                {
                    FlxG.log.warn("Item " + itemsData[Math.floor(item.y)][Math.floor(item.x)] + " at " + item.x + ":" + item.y + " isn't a " + match.type);
                }
            }
            else
            {
                removeItemActor(Math.floor(item.x), Math.floor(item.y), itemsData[Math.floor(item.y)][Math.floor(item.x)]);
                itemsData[Math.floor(item.y)][Math.floor(item.x)] = NONE;
            }
        }
        match.items.splice(0, match.items.length);
    }

    private function explosionResolve(match:MatchData):Void
    {
        // Set mins and maxes to opposite extreams to allow simple comparison to find them
        var minX = width + 1;
        var maxX = -1;
        var minY = height + 1;
        var maxY = -1;

        for (item in match.items)
        {
            if (item.x > maxX)
            {
                maxX = Math.floor(item.x);
            }

            if (item.x < minX)
            {
                minX = Math.floor(item.x);
            }

            if (item.y > maxY)
            {
                maxY = Math.floor(item.y);
            }

            if (item.y < minY)
            {
                minY = Math.floor(item.y);
            }
        }

        minX = Math.floor(Math.max(0, minX - 1));
        maxX = Math.floor(Math.min(width - 1, maxX + 1));
        minY = Math.floor(Math.max(0, minY - 1));
        maxY = Math.floor(Math.min(height - 1, maxY + 1));

        var newItems = new Array<FlxPoint>();

        for (y in minY...maxY + 1)
        {
            for (x in minX...maxX + 1)
            {
                newItems.push(FlxPoint.weak(x, y));
            }
        }

        match.items = newItems;

        defaultReslove(match, false);

        match.items.splice(0, match.items.length);
        score += 100;
    }

    private function lineResolve(match:MatchData):Void
    {
        if (match.items.length <= 3)
        {
            defaultReslove(match);
        }
        else if (match.items.length == 4)
        {
            var newItems = new Array<FlxPoint>();
            var horizontal = false;
            if (match.items[0].y == match.items[1].y)
            {
                horizontal = true;
            }
            if (horizontal)
            {
                for (x in 0...width)
                {
                    newItems.push(FlxPoint.weak(x, match.items[0].y));
                }
            }
            else
            {
                for (y in 0...height)
                {
                    newItems.push(FlxPoint.weak(match.items[0].x, y));
                }
            }
            match.items = newItems;

            defaultReslove(match, false);
        }
        else
        {
            var startX = match.items[0].x;
            var startY = match.items[0].y;
            var xMatches = 0;
            var yMatches = 0;
            for (item in match.items)
            {
                if (item.x == startX)
                {
                    xMatches++;
                }
                if (item.y == startY)
                {
                    yMatches++;
                }
            }
            if (xMatches == match.items.length || yMatches == match.items.length)
            {
                var newItems = new Array<FlxPoint>();
                for (x in 0...width)
                {
                    for (y in 0...height)
                    {
                        newItems.push(FlxPoint.weak(x, y));
                    }
                }
                match.items = newItems;
                score += 150;
                defaultReslove(match);
            }
            else
            {
                explosionResolve(match);
            }
        }
    }

    private function updateScore(itemType:MatchThreeItems, multiplier:Float = 1):Void
    {
        if (itemChanceData.exists(itemType))
        {
            score += Math.floor(itemChanceData.get(itemType).points * multiplier);
        }
    }

    private function fillBoardHoles():Void
    {
        var newItems = 0;
        for (x in 0...width)
        {
            var y = height - 1;
            while (y >= 0)
            {
                var lastY = 1;
                var changed = false;
                while (itemsData[y][x] == NONE)
                {
                    changed = true;
                    if (y - lastY < 0)
                    {
                        newItems++;
                        itemsData[y][x] = getRandomItem();
                    }
                    else
                    {
                        itemsData[y][x] = itemsData[y - lastY][x];
                        if (itemsData[y - lastY][x] == NONE)
                        {
                            lastY++;
                        }
                    }
                }
                // Re adding actor to fill the new item
                if (changed)
                {
                    var actor = createItem(x, y, itemsData[y][x]);
                    var itComp = cast(actor.getComponent(ActorComponentTypes.MATCHTHREEITEM), MatchThreeItemComponent);
                    if (y - lastY >= 0)
                    {
                        itemsData[y - lastY][x] = NONE;
                        removeItemActor(x, (y - lastY));
                        itComp.drop(startingX + x * actor.width, (startingY + (y - lastY) * actor.height));
                    }
                    else
                    {
                        itComp.drop(startingX + itComp.gridX * actor.width, (startingY + itComp.gridY * actor.height) - FlxG.height);
                    }
                    items[y].add(actor);
                }
                y--;
            }
        }
        resolvingMatches = false;
    }

    private function getRandomItem():MatchThreeItems
    {
        // Do a check if we can actually pick an item
        // And if not reset the repeats
        var possiblePicks = new Array<MatchThreeItems>();
        var possibleChances = new Array<Float>();
        for (i in 0...possibleItems.length)
        {
            if (itemRepeats.get(possibleItems[i]) < itemChanceData.get(possibleItems[i]).repeat)
            {
                possiblePicks.push(possibleItems[i]);
                possibleChances.push(itemChanceData.get(possibleItems[i]).chance);
            }
        }

        if (possiblePicks.length <= 0)
        {
            for (itemKey in itemRepeats.keys())
            {
                itemRepeats.set(itemKey, 0);
            }
            return getRandomItem();
        }

        var pick = possiblePicks[FlxG.random.weightedPick(possibleChances)];
        var repeatNum = itemRepeats.get(pick);
        repeatNum++;
        itemRepeats.set(pick, repeatNum);

        return pick;
    }

    private function checkItems():Bool
    {
        // Check all horizontal matches
        var hMatches = checkHorizontal();

        // Check vertical matches
        var vMatches = checkVertical();

        // Check if there is overlap only if we have vertical and horizontal matches
        compareMatches(vMatches, hMatches);

        if (matches.length > 0)
        {
            shouldReslove = true;
            return true;
        }

        return false;
    }

    private function canMatch():Bool
    {
        for (y in 0...height)
        {
            for (x in 0...width)
            {
                var mainItem = itemsData[y][x];

                // Swap all corners with mainItem and check to see if a match in vertical or horizontal

                // Top Middle
                if (y - 1 >= 0)
                {
                    itemsData[y][x] = itemsData[y - 1][x];
                    itemsData[y - 1][x] = mainItem;

                    if (checkHorizontal().length > 0 || checkVertical().length > 0)
                    {
                        itemsData[y - 1][x] = itemsData[y][x];
                        itemsData[y][x] = mainItem;
                        return true;
                    }


                    itemsData[y - 1][x] = itemsData[y][x];
                }

                if (x - 1 >= 0)
                {
                    // Left
                    itemsData[y][x] = itemsData[y][x - 1];
                    itemsData[y][x - 1] = mainItem;

                    if (checkHorizontal().length > 0 || checkVertical().length > 0)
                    {
                        itemsData[y][x - 1] = itemsData[y][x];
                        itemsData[y][x] = mainItem;
                        return true;
                    }

                    itemsData[y][x - 1] = itemsData[y][x];
                }

                // Right
                if (x + 1 < width)
                {
                    itemsData[y][x] = itemsData[y][x + 1];
                    itemsData[y][x + 1] = mainItem;

                    if (checkHorizontal().length > 0 || checkVertical().length > 0)
                    {
                        itemsData[y][x + 1] = itemsData[y][x];
                        itemsData[y][x] = mainItem;
                        return true;
                    }

                    itemsData[y][x + 1] = itemsData[y][x];
                }

                if (y + 1 < height)
                {
                    // Top Middle
                    itemsData[y][x] = itemsData[y + 1][x];
                    itemsData[y + 1][x] = mainItem;

                    if (checkHorizontal().length > 0 || checkVertical().length > 0)
                    {
                        itemsData[y + 1][x] = itemsData[y][x];
                        itemsData[y][x] = mainItem;
                        return true;
                    }

                    itemsData[y + 1][x] = itemsData[y][x];
                }

                itemsData[y][x] = mainItem;
            }
        }

        return false;
    }

    private function checkHorizontal():Array<Array<FlxPoint>>
    {
        var hMatches = new Array<Array<FlxPoint>>();
        var tempMatch:Array<FlxPoint> = null;
        for (y in 0...height)
        {
            for (x in 0...width)
            {
                if (tempMatch == null)
                {
                    tempMatch = new Array<FlxPoint>();
                }
                if (x > 0)
                {
                    if (itemsData[y][x] == itemsData[y][x - 1])
                    {
                        // Two in a row
                        tempMatch.push(new FlxPoint(x, y));
                    }
                    else if (tempMatch.length >= 3)
                    {
                        // this one doesn't match but it has 3 in it
                        hMatches.push(tempMatch);
                        tempMatch = new Array<FlxPoint>();
                        tempMatch.push(new FlxPoint(x, y));
                    }
                    else
                    {
                        // this one doesn't match and the temp array doesn't have 3
                        tempMatch = new Array<FlxPoint>();
                        tempMatch.push(new FlxPoint(x, y));
                    }
                }
                else
                {
                    // always add the first one
                    tempMatch.push(new FlxPoint(x, y));
                }
            }
            if (tempMatch != null && tempMatch.length >= 3 && itemsData[Math.floor(tempMatch[0].y)][Math.floor(tempMatch[0].x)] != NONE)
            {
                hMatches.push(tempMatch);
            }

            tempMatch = null;
        }

        return hMatches;
    }

    private function checkVertical():Array<Array<FlxPoint>>
    {
        var vMatches = new Array<Array<FlxPoint>>();
        var tempMatch:Array<FlxPoint> = null;
        for (x in 0...width)
        {
            for (y in 0...height)
            {
                if (tempMatch == null)
                {
                    tempMatch = new Array<FlxPoint>();
                }
                if (y > 0)
                {
                    if (itemsData[y][x] == itemsData[y - 1][x])
                    {
                        // Two in a row
                        tempMatch.push(new FlxPoint(x, y));
                    }
                    else if (tempMatch.length >= 3)
                    {
                        // this one doesn't match but it has 3 in it
                        vMatches.push(tempMatch);
                        tempMatch = new Array<FlxPoint>();
                        tempMatch.push(new FlxPoint(x, y));
                    }
                    else
                    {
                        // this one doesn't match and the temp array doesn't have 3
                        tempMatch = new Array<FlxPoint>();
                        tempMatch.push(new FlxPoint(x, y));
                    }
                }
                else
                {
                    // always add the first one
                    tempMatch.push(new FlxPoint(x, y));
                }
            }
            if (tempMatch != null && tempMatch.length >= 3 && itemsData[Math.floor(tempMatch[0].y)][Math.floor(tempMatch[0].x)] != NONE)
            {
                vMatches.push(tempMatch);
            }

            tempMatch = null;
        }

        return vMatches;
    }

    private function compareMatches(vMatches:Array<Array<FlxPoint>>, hMatches:Array<Array<FlxPoint>>):Void
    {
        // this feels like a really bad idea
        var vMatchesToRemove = new Array<Array<FlxPoint>>();
        var hMatchesToRemove = new Array<Array<FlxPoint>>();
        if (vMatches.length > 0 && hMatches.length > 0)
        {
            for (vMatch in vMatches)
            {
                for (hMatch in hMatches)
                {
                    var vtMatch = vMatch;
                    var vhMatch = hMatch;

                    var newMatch = compareMatch(vMatch, hMatch);

                    if (newMatch != null)
                    {
                        var match = { type:itemsData[Math.floor(newMatch[0].y)][Math.floor(newMatch[0].x)], items:newMatch };
                        vMatchesToRemove.push(vMatch);
                        hMatchesToRemove.push(hMatch);
                        matches.push(match);
                    }
                }
            }
        }

        for (match in vMatchesToRemove)
        {
            vMatches.remove(match);
        }

        for (match in hMatchesToRemove)
        {
            hMatches.remove(match);
        }

        for (vMatch in vMatches)
        {
            var match = { type:itemsData[Math.floor(vMatch[0].y)][Math.floor(vMatch[0].x)], items:vMatch };
            matches.push(match);
        }

        for (hMatch in hMatches)
        {
            var match = { type:itemsData[Math.floor(hMatch[0].y)][Math.floor(hMatch[0].x)], items:hMatch };
            matches.push(match);
        }
    }

    private function compareMatch(vMatch:Array<FlxPoint>, hMatch:Array<FlxPoint>):Array<FlxPoint>
    {
        var combine = false;
        for (vItem in vMatch)
        {
            for (hItem in hMatch)
            {
                if (vItem.x == hItem.x && vItem.y == hItem.y)
                {
                    vMatch.remove(vItem);
                    combine = true;
                }
            }
        }

        if (combine)
        {
            return hMatch.concat(vMatch);
        }

        return null;
    }

    private function createItem(x:Int, y:Int, itemType:MatchThreeItems):Actor
    {
        var af:ActorFactory = ActorFactory.GetInstance();
        var itemName:String = itemType.getName();
        var actor = af.createActor({
            "name": "item_" + x + "_" + y,
            "x": 0,
            "y": 0,
            "width": -1,
            "height": -1,
            "spriteSheet": "",
            "components": [
                {
                    "name": "MatchThreeItemComponent",
                    "data": {
                        "x": x,
                        "y": y,
                        "type": itemName
                    }
                }
            ]
        });

        var itComp = cast(actor.getComponent(ActorComponentTypes.MATCHTHREEITEM), components.matchthree.MatchThreeItemComponent);
        itComp.controller = this;

        return actor;
    }

    public function isResovling():Bool
    {
        return resolvingMatches || shouldSwitchCheck || shouldReslove ||
        noMatch || (numberOfItemsWaiting > 0) || (numberOfItemsSwitching > 0);
    }

    public function getStartingPoint():FlxPoint
    {
        return new FlxPoint(startingX, startingY);
    }

    public static function itemTypeFromString(itemName:String):MatchThreeItems
    {
        if (itemName.toUpperCase() == "FLOUR")
        {
            return FLOUR;
        }
        else if (itemName.toUpperCase() == "SUGAR")
        {
            return SUGAR;
        }
        else if (itemName.toUpperCase() == "MILK")
        {
            return MILK;
        }
        else if (itemName.toUpperCase() == "BUTTER")
        {
            return BUTTER;
        }
        else if (itemName.toUpperCase() == "SALT")
        {
            return SALT;
        }
        else if (itemName.toUpperCase() == "VANILLA")
        {
            return VANILLA;
        }
        else if (itemName.toUpperCase() == "COCONUT")
        {
            return COCONUT;
        }
        else if (itemName.toUpperCase() == "ALMOND")
        {
            return ALMOND;
        }
        else if (itemName.toUpperCase() == "CHOCOLATE")
        {
            return CHOCOLATE;
        }
        else if (itemName.toUpperCase() == "CARMEL")
        {
            return CARMEL;
        }
        else if (itemName.toUpperCase() == "PUMPKIN")
        {
            return PUMPKIN;
        }
        else if (itemName.toUpperCase() == "SPICE")
        {
            return SPICE;
        }
        else if (itemName.toUpperCase() == "CARROT")
        {
            return CARROT;
        }

        return NONE;
    }

    private function getItemActor(x:Int, y:Int, itemType:MatchThreeItems = null):Actor
    {
        if (y >= height || x >= width || y < 0 || x < 0)
        {
            FlxG.log.error("Can't get item at " + x + ":" + y + " because it's out of bounds.");
            return null;
        }
        var row = items[y];
        for (item in row)
        {
            var actor = cast(item, Actor);
            var aComponent = cast (actor.getComponent(ActorComponentTypes.MATCHTHREEITEM), MatchThreeItemComponent);
            if (itemType != null)
            {
                if (aComponent.gridX == x && itemType == aComponent.itemType)
                {
                    return actor;
                }
            }
            else if (aComponent.gridX == x)
            {
                return actor;
            }
        }

        FlxG.log.error("Can't get item at " + x + ":" + y + " because it can't be found.");
        return null;
    }

    private function removeItemActor(x:Int, y:Int, itemType:MatchThreeItems = null):Void
    {
        if (y >= height || x >= width || y < 0 || x < 0)
        {
            FlxG.log.error("Can't remove item at " + x + ":" + y + " because it's out of bounds.");
            return;
        }
        var row = items[y];
        for (item in row)
        {
            var actor = cast(item, Actor);
            var aComponent = cast (actor.getComponent(ActorComponentTypes.MATCHTHREEITEM), MatchThreeItemComponent);
            if (itemType != null)
            {
                if (aComponent.gridX == x && itemType == aComponent.itemType)
                {
                    aComponent.removeActorAnimation(meterX, meterY);
                    dyingItems.add(row.remove(item));
                    return;
                }
            }
            else if (aComponent.gridX == x)
            {
                row.remove(item).destroy();
                return;
            }
        }
    }

    public function switchItems(firstItemCords:FlxPoint, secondItemCords:FlxPoint, shouldCheck:Bool = true):Void
    {
        if (firstItemCords.x >= width || firstItemCords.y >= height || firstItemCords.x < 0 || firstItemCords.y < 0
        || secondItemCords.x >= width || secondItemCords.y >= height || secondItemCords.x < 0 || secondItemCords.y < 0)
        {
            FlxG.log.error("Corrdinates of item " + firstItemCords + " and " + secondItemCords + " are out of bounds.");
            return;
        }

        var firstActor = getItemActor(Math.floor(firstItemCords.x), Math.floor(firstItemCords.y));
        var secondActor = getItemActor(Math.floor(secondItemCords.x), Math.floor(secondItemCords.y));
        var firstComponent = cast(firstActor.getComponent(ActorComponentTypes.MATCHTHREEITEM), MatchThreeItemComponent);
        var secondComponent = cast(secondActor.getComponent(ActorComponentTypes.MATCHTHREEITEM), MatchThreeItemComponent);

        SoundManager.GetInstance().playSound("slide", Math.max(firstActor.x, secondActor.x), Math.max(firstActor.y, secondActor.y));

        firstComponent.gridX = Math.floor(secondItemCords.x);
        firstComponent.gridY = Math.floor(secondItemCords.y);
        secondComponent.gridX = Math.floor(firstItemCords.x);
        secondComponent.gridY = Math.floor(firstItemCords.y);

        var firstItem = itemsData[Math.floor(firstItemCords.y)][Math.floor(firstItemCords.x)];
        var secondItem = itemsData[Math.floor(secondItemCords.y)][Math.floor(secondItemCords.x)];

        if (firstItemCords.x == secondItemCords.x)
        {
            items[Math.floor(firstItemCords.y)].remove(firstActor);
            items[Math.floor(secondItemCords.y)].remove(secondActor);
            items[Math.floor(firstItemCords.y)].add(secondActor);
            items[Math.floor(secondItemCords.y)].add(firstActor);
        }

        itemsData[Math.floor(firstItemCords.y)][Math.floor(firstItemCords.x)] = secondItem;
        itemsData[Math.floor(secondItemCords.y)][Math.floor(secondItemCords.x)] = firstItem;

        lastSwitch = new Array<FlxPoint>();
        lastSwitch.push(firstItemCords);
        lastSwitch.push(secondItemCords);

        firstComponent.goToHome();
        secondComponent.goToHome();

        shouldSwitchCheck = shouldCheck;
    }

    private function shuffleBoard():Void
    {
        var allItems:Array<FlxSprite> = new Array<FlxSprite>();

        var tempCount = 0;
        for (row in items)
        {
            for (item in row.members)
            {
                row.remove(item);
                allItems.push(item);
                tempCount++;
            }
        }

        rand.shuffle(allItems);

        var row = 0;
        var x = 0;
        tempCount = 0;
        for (item in allItems)
        {
            tempCount++;
            var itemActor = cast(item, Actor);
            var itemComponent = cast(itemActor.getComponent(ActorComponentTypes.MATCHTHREEITEM), MatchThreeItemComponent);
            itemComponent.gridY = row;
            itemComponent.gridX = x;
            itemComponent.drop(startingX + x * item.width, (startingY + row * height) - FlxG.height);

            items[row].add(item);

            itemsData[row][x] = itemComponent.itemType;

            x++;
            if (x >= 5)
            {
                x = 0;
                row++;
            }
        }
    }

    private function shuffleTimer(t:FlxTimer):Void
    {
        shuffleBoard();
        noMatchImage.visible = false;
        noMatch = false;
    }

    private function getQuality():CupcakeQuality
    {
        var scoreDiff = maxScore - minScore;
        var midPoint = minScore + (scoreDiff / 2);
        var perfectOffset = scoreDiff / 8;
        var goodOffset = scoreDiff / 4;
        if (score > maxScore || score < minScore)
        {
            return CupcakeQuality.BAD;
        }
        else if (score < midPoint + perfectOffset && score > midPoint - perfectOffset)
        {
            return CupcakeQuality.PERFECT;
        }
        else if (score < midPoint + goodOffset && score > midPoint - goodOffset)
        {
            return CupcakeQuality.GOOD;
        }

        return CupcakeQuality.OKAY;
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
