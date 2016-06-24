// MatchThreeController.hx -- Controls the match three mini-game itemsData and flow
package components;

import flixel.FlxG;
import flixel.math.FlxPoint;
import flixel.math.FlxRandom;
import flixel.group.FlxGroup.FlxTypedGroup;
import Actor;
import ActorFactory;
import flixel.FlxSprite;

typedef MatchData = Array<FlxPoint>;

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

	private var resolvingMatches = false;
	private var shouldReslove = false;
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
	
	public function init(Data:Dynamic):Bool {
		itemsData = new Array<Array<MatchThreeItems>>();
		matches = new Array<MatchData>();
		rand = new FlxRandom();
		items = new Array<FlxTypedGroup<FlxSprite>>();

		possibleItems = new Array<MatchThreeItems>();
		possibleItems.push(FLOUR);
		possibleItems.push(SUGAR);
		possibleItems.push(SALT);
		possibleItems.push(MILK);
		possibleItems.push(BUTTER);

		randomItemPercentageChange = [22, 22, 22, 22, 12];

		generateBoard();

		//FlxG.log.add(itemsData[0][0]);
		//FlxG.log.add(itemsData[width-1][height-1]);

		return true;
	}

	public function postInit():Void {
		checkItems();
	}

	public function update(DeltaTime:Float):Void {
		var rowCount = 0;
		for (row in itemsData) {
			FlxG.watch.addQuick("Item row " + rowCount, row);
			rowCount++;
		}

		FlxG.watch.addQuick("Score", score);
		//FlxG.watch.addQuick("Number of matches", matches.length);
		if (shouldReslove && numberOfItemsWaiting <= 0) {
			resolveMatches();
		}
	}

	public function getComponentID():ActorComponentTypes {
		return ActorComponentTypes.MATCHTHREE;
	}

	public function onAdd(Owner:Dynamic):Void {
		for (row in items) {
			Owner.add(row);
		}
	}

	public function destroy():Void {
		for (match in matches) {
			for (item in match) {
				var tempItem = item;
				match.remove(item);
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
				updateScore(itemsData[Math.floor(match[0].y)][Math.floor(match[0].x)], match.length);
				for (item in match) {
					// Have to remove data and actual actors
					removeItemActor(Math.floor(item.x), Math.floor(item.y), itemsData[Math.floor(item.y)][Math.floor(item.x)] );
					itemsData[Math.floor(item.y)][Math.floor(item.x)] = NONE;
					numberRemoved++;
					//FlxG.log.add("Removing item " + Math.floor(item.x) + ":" + Math.floor(item.y));
				}
				matches.remove(match);
			}
			//FlxG.log.add("Removing " + numberRemoved + " items.");
			numberOfMatches = matches.length;
			fillBoardHoles();
			checkItems();
		}
	}

	private function updateScore(itemType:MatchThreeItems, amount:Int):Void {
		score += itemType.getIndex() * amount;
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
			if (tempMatch != null && tempMatch.length >= 3) {
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
			if (tempMatch != null && tempMatch.length >= 3) {
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
		if (vMatches.length > 0 && hMatches.length > 0) {
			for (vMatch in vMatches) {
				for (hMatch in hMatches) {
					var vtMatch = vMatch;
					var vhMatch = hMatch;

					var newMatch = compareMatch(vMatch, hMatch);

					if (newMatch != null) {
						vMatches.remove(vMatch);
						hMatches.remove(hMatch);
						matches.push(newMatch);
					}
				}
			}
		}
			
		for (vMatch in vMatches) {
			matches.push(vMatch);
		}

		for (hMatch in hMatches) {
			matches.push(hMatch);
		}
	}

	private function compareMatch(vMatch:Array<FlxPoint>, hMatch:Array<FlxPoint>):Array<FlxPoint> {
		var combine = false;
		for (vItem in vMatch) {
			for (hItem in hMatch) {
				if (vItem.x == hItem.x && vItem.y == hItem.y) {
					combine = true;
					break;
				}
			}
			if (combine) {
				break;
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

		numberOfItemsWaiting++;

		return actor;
	}

	public function isResovling():Bool {
		return resolvingMatches;	
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

		FlxG.log.error("Can't remove item at " + x + ":" + y + " because it can't be found.");
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

		if (shouldCheck) {
			if (!checkItems()) {
				//FlxG.log.add("Switching back.");
				switchItems(firstItemCords, secondItemCords, false);
			}
		}
	}
}
