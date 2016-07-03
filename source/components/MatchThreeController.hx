// MatchThreeController.hx -- Controls the match three mini-game itemsData and flow
package components;

import flixel.FlxG;
import flixel.math.FlxPoint;
import flixel.math.FlxRandom;
import flixel.group.FlxGroup.FlxTypedGroup;
import Actor;
import ActorFactory;
import flixel.FlxSprite;
import flixel.util.FlxTimer;
import util.MultiIterator;

typedef MatchData = { type:MatchThreeItems, items:Array<FlxPoint> };

enum MatchThreeItems {
	NONE;
	FLOUR;
	SUGAR;
	SALT;
	MILK;
	BUTTER;
}

class MatchThreeController implements ActorComponent {

	public var owner:Actor;

	private static var itemChances = [20, 20, 15, 20, 20];

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

	private var matches:Array<MatchData>;
	private var possibleItems:Array<MatchThreeItems>;
	private var randomItemPercentageChange:Array<Float>;
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

	private var noMatchTimer:FlxTimer;
	private var noMatchTime = 1;
	private var noMatchImage:FlxSprite;

	private var timerStartX = 0;
	private var timerSTartY = 178;
	private var matchTime = 120;
	private var timer:FlxTimer;	
	private var timerComponent:MatchThreeTimerComponent;

	public function init(Data:Dynamic):Bool {
		itemsData = new Array<Array<MatchThreeItems>>();
		matches = new Array<MatchData>();
		rand = new FlxRandom();
		items = new Array<FlxTypedGroup<FlxSprite>>();
		lastSwitch = new Array<FlxPoint>();

		maxScore = Reflect.field(Data, "score");
		matchTime = Reflect.field(Data, "time");

		setUpMeter();

		setUpItems(Reflect.field(Data, "items"));

		setUpTimers();

		//FlxG.log.add(itemsData[0][0]);
		//FlxG.log.add(itemsData[width-1][height-1]);

		return true;
	}

	private function endLevel(t:FlxTimer):Void {
		FlxG.switchState(new PlayState());
	}

	private function setUpMeter():Void {
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

		meter = cast(meterActor.getComponent(ActorComponentTypes.MATCHMETER), components.MatchThreeMeterComponent);
	}

	private function setUpItems(?items:Array<String>=null):Void {
		possibleItems = new Array<MatchThreeItems>();
		if (items == null) {
			possibleItems.push(FLOUR);
			possibleItems.push(SUGAR);
			possibleItems.push(SALT);
			possibleItems.push(MILK);
			possibleItems.push(BUTTER);
		} else {
			for (item in items) {
				possibleItems.push(MatchThreeController.itemTypeFromString(item));
			}
		}
		
		generateItemChance();
		generateBoard();
	}


	private function generateItemChance():Void {
		randomItemPercentageChange = new Array<Float>();

		for (i in 0...possibleItems.length) {
			randomItemPercentageChange[i] = itemChances[possibleItems[i].getIndex()-1];
		}
	}

	private function setUpTimers():Void {
		timer = new FlxTimer();
		timer.start(matchTime, endLevel, 1);

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
						"time": matchTime
					}
				}
			]
		});

		timerComponent = cast(timerActor.getComponent(ActorComponentTypes.MATCHTIMER), MatchThreeTimerComponent);

		noMatchTimer = new FlxTimer();
		noMatchImage = new FlxSprite();
		noMatchImage.loadGraphic(AssetPaths.nomatch__png);
		noMatchImage.x = FlxG.width/2 - noMatchImage.width/2;
		noMatchImage.y = FlxG.height/2 - noMatchImage.height/2;
		noMatchImage.visible = false;
	}

	public function postInit():Void {
		//checkItems();
	}

	public function update(DeltaTime:Float):Void {
		#if !NO_FLX_DEBUG
		var rowCount = 0;
		for (row in itemsData) {
			FlxG.watch.addQuick("Item row " + rowCount, row);
			rowCount++;
		}

		FlxG.watch.addQuick("Score", score);
		//FlxG.watch.addQuick("Items Waiting", numberOfItemsWaiting);
		//FlxG.watch.addQuick("Items Switching", numberOfItemsSwitching);
		//FlxG.watch.addQuick("Should Resolve", shouldReslove);
		//FlxG.watch.addQuick("Switch Check", shouldSwitchCheck);
		//FlxG.watch.addQuick("Number of matches", matches.length);

		FlxG.watch.addQuick("possible items", possibleItems);
		FlxG.watch.addQuick("item chances", randomItemPercentageChange);
		if (FlxG.keys.justPressed.R) {
			shuffleBoard();
		}

		#end


		if (shouldSwitchCheck && numberOfItemsSwitching <= 0 && numberOfItemsWaiting <= 0 && !noMatch) {
			if (!checkItems()) {
				//FlxG.log.add("Switching back.");
				switchItems(lastSwitch[0], lastSwitch[1], false);
			}

			shouldSwitchCheck = false;
		} else if (shouldReslove && numberOfItemsWaiting <= 0 && numberOfItemsSwitching <= 0&& !noMatch) {
			resolveMatches();
		} else if (numberOfItemsWaiting <= 0 && numberOfItemsSwitching <= 0 && !shouldSwitchCheck && !shouldReslove&& !noMatch) {
			if (!checkItems()) {
				if (!canMatch()) {
					//FlxG.log.error("Can find a match");
					noMatch = true;
					noMatchImage.visible = true;
					noMatchTimer.start(noMatchTime, shuffleTimer, 1);
				}
			}
		}

		meter.score = this.score;
		timerComponent.time = timer.elapsedTime;
	}

	public function getComponentID():ActorComponentTypes {
		return ActorComponentTypes.MATCHTHREE;
	}

	public function onAdd(Owner:Dynamic):Void {
		for (row in items) {
			Owner.add(row);
		}

		meter.owner.addToState(Owner);
		timerComponent.owner.addToState(Owner);
		Owner.add(noMatchImage);
	}

	public function destroy():Void {
		for (match in matches) {
			for (item in match.items) {
				var tempItem = item;
				match.items.remove(item);
				tempItem.destroy();
			}
		}
	}

	private function generateBoard():Void {

		for (y in 0...height) {
			var row = new Array<MatchThreeItems>();
			var itemRow = new FlxTypedGroup<FlxSprite>();
			for (x in 0...width) {
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

	private function resolveMatches():Void {
		if (matches.length > 0 && !resolvingMatches) {
			shouldReslove = false;
			resolvingMatches = true;
			numberOfMatches = matches.length;
			var numberRemoved = 0;
			for (match in matches) {
				resloveMatch(match);
			}

			matches.splice(0, matches.length);

			//FlxG.log.add("Removing " + numberRemoved + " items.");
			numberOfMatches = matches.length;
			fillBoardHoles();
			//checkItems();
		}
	}

	private function resloveMatch(match:MatchData):Void {
		updateScore(itemsData[Math.floor(match.items[0].y)][Math.floor(match.items[0].x)], match.items.length);
		// FlxG.log.add("Removing item of type " + itemsData[Math.floor(match.items[0].y)][Math.floor(match.items[0].x)]);
		switch (match.type) {
			case SALT:
				explosionResolve(match);
			default:
				defaultReslove(match);
		}
	}

	private function defaultReslove(match:MatchData, ?checkType:Bool=true):Void {
		for (item in match.items) {
			// Have to remove data and actual actors
			if (checkType) {
				if (itemsData[Math.floor(item.y)][Math.floor(item.x)] == match.type) {
					removeItemActor(Math.floor(item.x), Math.floor(item.y), itemsData[Math.floor(item.y)][Math.floor(item.x)] );
					itemsData[Math.floor(item.y)][Math.floor(item.x)] = NONE;
				} else if (itemsData[Math.floor(item.y)][Math.floor(item.x)] != NONE) {
					FlxG.log.error("Item " + itemsData[Math.floor(item.y)][Math.floor(item.x)] + " at " + item.x + ":" + item.y + " isn't a " + match.type);
				}
			} else {
				removeItemActor(Math.floor(item.x), Math.floor(item.y), itemsData[Math.floor(item.y)][Math.floor(item.x)] );
				itemsData[Math.floor(item.y)][Math.floor(item.x)] = NONE;
			}
			//FlxG.log.add("Removing item " + Math.floor(item.x) + ":" + Math.floor(item.y));
		}
		match.items.splice(0, match.items.length);
	}

	private function explosionResolve(match:MatchData):Void {
		// Set mins and maxes to opposite extreams to allow simple comparison to find them
		var minX = width+1;
		var maxX = -1;
		var minY = height+1;
		var maxY = -1;

		for (item in match.items) {
			if (item.x > maxX) {
				maxX = Math.floor(item.x);
			} 

			if (item.x < minX) {
				minX = Math.floor(item.x);
			}

			if (item.y > maxY) {
				maxY = Math.floor(item.y);
			} 

			if (item.y < minY) {
				minY = Math.floor(item.y);
			}
		}

		minX = Math.floor(Math.max(0, minX-1));
		maxX = Math.floor(Math.min(width-1, maxX+1));
		minY = Math.floor(Math.max(0, minY-1));
		maxY =Math.floor(Math.min(height-1, maxY+1));

		var newItems = new Array<FlxPoint>();

		for (y in minY...maxY+1) {
			for (x in minX...maxX+1) {
				newItems.push(FlxPoint.weak(x, y));
			}
		}

		match.items = newItems;

		defaultReslove(match, false);

		match.items.splice(0, match.items.length);
	}

	private function updateScore(itemType:MatchThreeItems, amount:Int):Void {
		switch (itemType) {
			case SALT:
				score += (6 + amount * 3) * amount;
			default:
				score += 5 * amount;
		}
	}

	private function fillBoardHoles():Void {
		//FlxG.log.add("Filling board back up");
		var newItems = 0;
		for (x in 0...width) {
			//FlxG.log.add("X:" + x);
			var y = height-1;
			while (y >= 0) {
				//FlxG.log.add("Y:" + y);
				var lastY = 1;
				//FlxG.log.add("Checking coll " + y + " for none itemsData");
				var changed = false;
				while(itemsData[y][x] == NONE) {
					changed = true;
					if (y - lastY <  0) {
						newItems++;
						//FlxG.log.add("At the top of coll " + y + " so we need a new item.");
						itemsData[y][x] = getRandomItem();
					} else {
						//FlxG.log.add("Replacing item at " + x + ":" + y + " with item " + itemsData[y-lastY][x] + " at " + x + ":" + y);
						itemsData[y][x] = itemsData[y-lastY][x];
						//itemsData[y-lastY][x] = NONE;
						if (itemsData[y-lastY][x] == NONE){
							lastY++;
						}
					}
				}
				// Re adding actor to fill the new item
				if (changed) {
					var actor = createItem(x, y, itemsData[y][x]);
					var itComp = cast(actor.getComponent(ActorComponentTypes.MATCHTHREEITEM), MatchThreeItemComponent);
					if (y - lastY >= 0){
						itemsData[y- lastY][x] = NONE;
						removeItemActor(x, (y-lastY));
						itComp.drop(startingX + x * actor.width, (startingY + (y-lastY) * actor.height));
					} else {
						itComp.drop(startingX + itComp.gridX * actor.width, (startingY + itComp.gridY * actor.height) - FlxG.height);
					}
					items[y].add(actor);
				}
				y--;
			}
		}

		//FlxG.log.add("Creating " + newItems + " new items.");
		resolvingMatches = false;
	}

	private function getRandomItem():MatchThreeItems {
		return possibleItems[rand.weightedPick(randomItemPercentageChange)];
	}

	private function checkItems():Bool {
		// Check all horizontal matches
		var hMatches = checkHorizontal();

		// Check vertical matches
		var vMatches = checkVertical();

		// Check if there is overlap only if we have vertical and horizontal matches
		compareMatches(vMatches, hMatches);

		if (matches.length > 0) {
			shouldReslove = true;
			return true;
		}

		return false;
	}

	private function canMatch():Bool {
		//var yIterator:MultiIterator = new MultiIterator(1, height-1, 2);
		for (y in 0...height) {
			//var xIterator:MultiIterator = new MultiIterator(1, width-1, 2);
			for (x in 0...width) {
				var mainItem = itemsData[y][x];

				// Swap all corners with mainItem and check to see if a match in vertical or horizontal

				// Top Middle
				if (y-1 >= 0) {
					itemsData[y][x] = itemsData[y-1][x];
					itemsData[y-1][x] = mainItem;

					if (checkHorizontal().length>0 || checkVertical().length>0){
						itemsData[y-1][x] = itemsData[y][x];
						itemsData[y][x] = mainItem;
						return true;
					}


					itemsData[y-1][x] = itemsData[y][x];
				}

				if (x-1 >= 0) {
					// Left
					itemsData[y][x] = itemsData[y][x-1];
					itemsData[y][x-1] = mainItem;

					if (checkHorizontal().length>0 || checkVertical().length>0){
						itemsData[y][x-1] = itemsData[y][x];
						itemsData[y][x] = mainItem;
						return true;
					}

					itemsData[y][x-1] = itemsData[y][x];
				}

				// Right
				if (x+1 < width) {
					itemsData[y][x] = itemsData[y][x+1];
					itemsData[y][x+1] = mainItem;

					if (checkHorizontal().length > 0 || checkVertical().length>0){
						itemsData[y][x+1] = itemsData[y][x];
						itemsData[y][x] = mainItem;
						return true;
					}

					itemsData[y][x+1] = itemsData[y][x];
				}

				if (y+1 < height) {
					// Top Middle
					itemsData[y][x] = itemsData[y+1][x];
					itemsData[y+1][x] = mainItem;

					if (checkHorizontal().length>0 || checkVertical().length>0){
						itemsData[y+1][x] = itemsData[y][x];
						itemsData[y][x] = mainItem;
						return true;
					}

					itemsData[y+1][x] = itemsData[y][x];
				}

				itemsData[y][x] = mainItem;
			}
		}

		return false;
	}

	private function checkHorizontal():Array<Array<FlxPoint>> {
		var hMatches = new Array<Array<FlxPoint>>();
		var tempMatch:Array<FlxPoint> = null;
		for (y in 0...height) {
			for (x in 0...width) {
				if (tempMatch == null) {
					tempMatch = new Array<FlxPoint>();
				}
				if (x > 0) {
					//FlxG.log.add(itemsData[y][x] + " is " + itemsData[y][x-1] + " ? " + (itemsData[y][x] == itemsData[y][x-1]));
					if (itemsData[y][x] == itemsData[y][x-1]) {
						// Two in a row
						//FlxG.log.add("Adding point " + x + ":" + y + " to temp array");
						tempMatch.push(new FlxPoint(x, y));
					} else if (tempMatch.length >= 3) {
						// this one doesn't match but it has 3 in it
						//FlxG.log.add("Adding temp array to matches and nulling tempMatch");
						hMatches.push(tempMatch);
						tempMatch = new Array<FlxPoint>();
						tempMatch.push(new FlxPoint(x, y));
					} else {
						//FlxG.log.add("Nulling temp match");
						// this one doesn't match and the temp array doesn't have 3
						tempMatch = new Array<FlxPoint>();
						tempMatch.push(new FlxPoint(x, y));
					}
				} else {
					// always add the first one
					//FlxG.log.add("Adding first point " + x + ":" + y + " to temp array");
					tempMatch.push(new FlxPoint(x, y));
				}
			}
			if (tempMatch != null && tempMatch.length >= 3 && itemsData[Math.floor(tempMatch[0].y)][Math.floor(tempMatch[0].x)] != NONE) {
				hMatches.push(tempMatch);
			}

			tempMatch = null;
		}

		/*FlxG.log.add(hMatches.length + " horizontal matches");
		for (match in hMatches) {
			FlxG.log.add("horizontal match " + match);
		}
		*/

		return hMatches;
	}

	private function checkVertical():Array<Array<FlxPoint>> {
		var vMatches = new Array<Array<FlxPoint>>();
		var tempMatch:Array<FlxPoint> = null;
		for (x in 0...width) {
			for (y in 0...height) {
				if (tempMatch == null) {
					tempMatch = new Array<FlxPoint>();
				}
				if (y > 0) {
					if (itemsData[y][x] == itemsData[y-1][x]) {
						// Two in a row
						tempMatch.push(new FlxPoint(x, y));
					} else if (tempMatch.length >= 3) {
						// this one doesn't match but it has 3 in it
						vMatches.push(tempMatch);
						/*FlxG.log.add("Found a veritcal match of ");
						for (match in tempMatch) {
							//FlxG.log.add(itemsData[Math.floor(match.y)][Math.floor(match.x)] + "_" + match.x + ":" + match.y);
						}
						*/
						tempMatch = new Array<FlxPoint>();
						tempMatch.push(new FlxPoint(x, y));
					} else {
						// this one doesn't match and the temp array doesn't have 3
						tempMatch = new Array<FlxPoint>();
						tempMatch.push(new FlxPoint(x, y));
					}
				} else {
					// always add the first one
					tempMatch.push(new FlxPoint(x, y));
				}
			}
			if (tempMatch != null && tempMatch.length >= 3 && itemsData[Math.floor(tempMatch[0].y)][Math.floor(tempMatch[0].x)] != NONE) {
				vMatches.push(tempMatch);
				/*FlxG.log.add("Found a veritcal match of ");
				for (match in tempMatch) {
					//FlxG.log.add(itemsData[Math.floor(match.y)][Math.floor(match.x)] + "_" + match.x + ":" + match.y);
				}*/
			}

			tempMatch = null;
		}

		/*
		FlxG.log.add(vMatches.length + " vertical matches");
		for (match in vMatches) {
			FlxG.log.add("Vertical match " + match);
		}
		*/
		return vMatches;
	}

	private function compareMatches(vMatches:Array<Array<FlxPoint>>, hMatches:Array<Array<FlxPoint>>):Void {
		// this feels like a really bad idea
		var vMatchesToRemove = new Array<Array<FlxPoint>>();
		var hMatchesToRemove = new Array<Array<FlxPoint>>();
		if (vMatches.length > 0 && hMatches.length > 0) {
			for (vMatch in vMatches) {
				for (hMatch in hMatches) {
					var vtMatch = vMatch;
					var vhMatch = hMatch;

					var newMatch = compareMatch(vMatch, hMatch);

					if (newMatch != null) {
						var match = { type:itemsData[Math.floor(newMatch[0].y)][Math.floor(newMatch[0].x)], items:newMatch };
						//vMatches.remove(vMatch);
						//hMatches.remove(hMatch);
						vMatchesToRemove.push(vMatch);
						hMatchesToRemove.push(hMatch);
						matches.push(match);
					}
				}
			}
		}

		for(match in vMatchesToRemove) {
			vMatches.remove(match);
		}

		for (match in hMatchesToRemove) {
			hMatches.remove(match);
		}
			
		for (vMatch in vMatches) {
			var match = { type:itemsData[Math.floor(vMatch[0].y)][Math.floor(vMatch[0].x)], items:vMatch };
			matches.push(match);
		}

		for (hMatch in hMatches) {
			var match = { type:itemsData[Math.floor(hMatch[0].y)][Math.floor(hMatch[0].x)], items:hMatch };
			matches.push(match);
		}
	}

	private function compareMatch(vMatch:Array<FlxPoint>, hMatch:Array<FlxPoint>):Array<FlxPoint> {
		var combine = false;
		for (vItem in vMatch) {
			for (hItem in hMatch) {
				if (vItem.x == hItem.x && vItem.y == hItem.y) {
					vMatch.remove(vItem);
					combine = true;
				}
			}
		}

		if (combine) {
			return hMatch.concat(vMatch);
		}

		return null;
	}

	private function createItem(x:Int, y:Int, itemType:MatchThreeItems): Actor {
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

		var itComp = cast(actor.getComponent(ActorComponentTypes.MATCHTHREEITEM), components.MatchThreeItemComponent);
		itComp.controller = this;

		//numberOfItemsWaiting++;

		return actor;
	}

	public function isResovling():Bool {
		return resolvingMatches || shouldSwitchCheck || shouldReslove ||
		 noMatch || (numberOfItemsWaiting > 0) || (numberOfItemsSwitching > 0);	
	}

	public function getStartingPoint():FlxPoint {
		return new FlxPoint(startingX, startingY);
	}

	public static function itemTypeFromString(itemName:String):MatchThreeItems {
		if (itemName.toUpperCase() == "FLOUR") {
			return FLOUR;
		} else if (itemName.toUpperCase() == "SUGAR") {
			return SUGAR;
		} else if (itemName.toUpperCase() == "MILK") {
			return MILK;
		} else if (itemName.toUpperCase() == "BUTTER") {
			return BUTTER;
		} else if (itemName.toUpperCase() == "SALT") {
			return SALT;
		}

		return NONE;
	}

	private function getItemActor(x:Int, y:Int, itemType:MatchThreeItems=null):Actor {
		if (y >= height || x >= width || y < 0 || x < 0) {
			FlxG.log.error("Can't get item at " + x + ":" + y + " because it's out of bounds.");
			return null;
		}
		var row = items[y];
		//FlxG.log.add("Looking for an item in a row of " + row.length);
		for (item in row) {
			var actor = cast(item, Actor);
			var aComponent = cast (actor.getComponent(ActorComponentTypes.MATCHTHREEITEM), MatchThreeItemComponent);
			if (itemType != null){
				if (aComponent.gridX == x && itemType == aComponent.itemType) {
					//FlxG.log.add("Getting " + aComponent.itemType + " at " + x + ":" + y);
					return actor;
				}
			} else if (aComponent.gridX == x) {
				//FlxG.log.add("Getting " + aComponent.itemType + " at " + x + ":" + y);
				return actor;
			}
		}

		FlxG.log.error("Can't get item at " + x + ":" + y + " because it can't be found.");
		return null;
	}

	private function removeItemActor(x:Int, y:Int, itemType:MatchThreeItems=null):Void {
		if (y >= height || x >= width || y < 0 || x < 0) {
			FlxG.log.error("Can't remove item at " + x + ":" + y + " because it's out of bounds.");
			return;
		}
		var row = items[y];
		//FlxG.log.add("Removing an item in a row of " + row.length);
		for (item in row) {
			var actor = cast(item, Actor);
			var aComponent = cast (actor.getComponent(ActorComponentTypes.MATCHTHREEITEM), MatchThreeItemComponent);
			if (itemType != null){
				if (aComponent.gridX == x && itemType == aComponent.itemType) {
					//FlxG.log.add("Removing " + aComponent.itemType + " at " + x + ":" + y);
					row.remove(item).destroy();
					return;
				}
			} else if (aComponent.gridX == x) {
				//FlxG.log.add("Removing " + aComponent.itemType + " at " + x + ":" + y);
				row.remove(item).destroy();
				return;
			}
		}

		//FlxG.log.warn("Can't remove item at " + x + ":" + y + " because it can't be found (Probablly already removed).");
	}

	public function switchItems(firstItemCords:FlxPoint, secondItemCords:FlxPoint, shouldCheck:Bool=true):Void {
		if (firstItemCords.x >= width || firstItemCords.y >= height || firstItemCords.x < 0 || firstItemCords.y < 0
			|| secondItemCords.x >= width || secondItemCords.y >= height || secondItemCords.x < 0 || secondItemCords.y < 0) {
			FlxG.log.error("Corrdinates of item " + firstItemCords + " and " + secondItemCords + " are out of bounds.");
			return;
		}

		var firstActor = getItemActor(Math.floor(firstItemCords.x), Math.floor(firstItemCords.y));
		var secondActor = getItemActor(Math.floor(secondItemCords.x), Math.floor(secondItemCords.y));
		var firstComponent = cast(firstActor.getComponent(ActorComponentTypes.MATCHTHREEITEM), MatchThreeItemComponent);
		var secondComponent = cast(secondActor.getComponent(ActorComponentTypes.MATCHTHREEITEM), MatchThreeItemComponent);
		
		firstComponent.gridX = Math.floor(secondItemCords.x);
		firstComponent.gridY = Math.floor(secondItemCords.y);
		secondComponent.gridX = Math.floor(firstItemCords.x);
		secondComponent.gridY = Math.floor(firstItemCords.y);

		var firstItem = itemsData[Math.floor(firstItemCords.y)][Math.floor(firstItemCords.x)];
		var secondItem = itemsData[Math.floor(secondItemCords.y)][Math.floor(secondItemCords.x)];

		if (firstItemCords.x == secondItemCords.x) {
			//FlxG.log.add("Swaping items " + firstItem + "_" + firstItemCords.x + ":" + firstItemCords.y + " and ");
			//FlxG.log.add(secondItem + "_" + secondItemCords.x + ":" + secondItemCords.y);
			//FlxG.log.add(firstComponent.itemType + " is now at " + firstComponent.gridX + ":" + firstComponent.gridY);
			//FlxG.log.add(secondComponent.itemType + " is now at " + secondComponent.gridX + ":" + secondComponent.gridY);
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

	private function shuffleBoard():Void {
		//FlxG.log.add("Starting shuffle");
		var allItems:Array<FlxSprite> = new Array<FlxSprite>();

		var tempCount = 0;
		for (row in items) {
			for (item in row.members) {
				row.remove(item);
				allItems.push(item);
				tempCount++;
			}
		}
		//FlxG.log.add("Shuffling " + tempCount + " items.");

		rand.shuffleArray(allItems, allItems.length*2);

		var row = 0;
		var x = 0;
		tempCount = 0;
		for (item in allItems) {
			tempCount++;
			var itemActor = cast(item, Actor);
			var itemComponent = cast(itemActor.getComponent(ActorComponentTypes.MATCHTHREEITEM), MatchThreeItemComponent);
			itemComponent.gridY = row;
			itemComponent.gridX = x;
			itemComponent.drop(startingX + x * item.width, (startingY + row * height) - FlxG.height);

			items[row].add(item);

			itemsData[row][x] = itemComponent.itemType;

			x++;
			if (x >= 5) {
				x = 0;
				row++;
			}

			//FlxG.log.add("Item " + itemComponent.itemType + " is now at " + x + ":" + row);
		}
		//FlxG.log.add("Done shuffling " + tempCount + " itmes");
	}

	private function shuffleTimer(t:FlxTimer):Void {
		shuffleBoard();
		noMatchImage.visible = false;
		noMatch = false;
	}

	public function onMouseEvent(e:MOUSEEVENT):Void{}
}
