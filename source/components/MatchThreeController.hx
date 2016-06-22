// MatchThreeController.hx -- Controls the match three mini-game items and flow
package components;

import flixel.FlxG;
import flixel.math.FlxPoint;
import flixel.math.FlxRandom;

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
	private var score = 0;

	private var width = 5;
	private var height = 5;
	private var startingX = 86;
	private var startingY = 10;
	private var itemSize = 44;

	private var items:Array<Array<MatchThreeItems>>; // [Row][Column]
	private var matches:Array<MatchData>;
	private var possibleItems:Array<MatchThreeItems>;
	private var numberOfMatches = 0;

	private var rand:FlxRandom;
	
	public function init(Data:Dynamic):Bool {
		items = new Array<Array<MatchThreeItems>>();
		matches = new Array<MatchData>();
		rand = new FlxRandom();

		possibleItems = new Array<MatchThreeItems>();
		possibleItems.push(FLOUR);
		possibleItems.push(SUGAR);
		possibleItems.push(SALT);
		possibleItems.push(MILK);
		possibleItems.push(BUTTER);
		generateBoard();

		//FlxG.log.add(items[0][0]);
		//FlxG.log.add(items[width-1][height-1]);

		return true;
	}

	public function postInit():Void {
		checkItems();
	}

	public function update(DeltaTime:Float):Void {
		var rowCount = 0;
		for (row in items) {
			FlxG.watch.addQuick("Item row " + rowCount, row);
			rowCount++;
		}

		resolveMatches();

		FlxG.watch.addQuick("Score", score);
		//FlxG.watch.addQuick("Number of matches", matches.length);
	}

	public function getComponentID():ActorComponentTypes {
		return ActorComponentTypes.MATCHTHREE;
	}

	public function onAdd(Owner:Dynamic):Void {

	}

	public function destory():Void {
	}

	private function generateBoard():Void {
		for (y in 0...height) {
			var row = new Array<MatchThreeItems>();
			for (x in 0...width) {
				row.push(getRandomItem());			
			}
			items.push(row);
		}
	}

	private function resolveMatches():Void {
		if (matches.length > 0 && !resolvingMatches) {
			resolvingMatches = true;
			numberOfMatches = matches.length;
			for (match in matches) {
				updateScore(items[Math.floor(match[0].y)][Math.floor(match[0].x)], match.length);
				for (item in match) {
					items[Math.floor(item.y)][Math.floor(item.x)] = NONE;
					//FlxG.log.add("Removing item " + Math.floor(item.x) + ":" + Math.floor(item.y));
				}
				matches.remove(match);
			}
			numberOfMatches = 0;
			fillBoardHoles();
		}
	}

	private function updateScore(itemType:MatchThreeItems, amount:Int):Void {
		score += itemType.getIndex() * amount;
	}

	private function fillBoardHoles():Void {
		//FlxG.log.add("Filling board back up");
		for (x in 0...width) {
			//FlxG.log.add("X:" + x);
			var y = height-1;
			while (y >= 0) {
				//FlxG.log.add("Y:" + y);
				var lastY = 1;
				//FlxG.log.add("Checking coll " + y + " for none items");
				while(items[y][x] == NONE) {
					if (y - lastY <  0) {
						//FlxG.log.add("At the top of coll " + y + " so we need a new item.");
						items[y][x] = getRandomItem();
					} else {
						//FlxG.log.add("Replacing item at " + x + ":" + y + " with item " + items[y-lastY][x] + " at " + x + ":" + y);
						items[y][x] = items[y-lastY][x];
						lastY++;
					}
				}

				y--;
			}
		}

		resolvingMatches = false;
	}

	private function getRandomItem():MatchThreeItems {
		return possibleItems[rand.int(0, possibleItems.length - 1)];
	}

	private function checkItems():Bool {
		// Check all horizontal matches
		var hMatches = checkHorizontal();

		// Check vertical matches
		var vMatches = checkVertical();

		// Check if there is overlap only if we have vertical and horizontal matches
		compareMatches(vMatches, hMatches);

		if (matches.length > 0) {
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
					//FlxG.log.add(items[y][x] + " is " + items[y][x-1] + " ? " + (items[y][x] == items[y][x-1]));
					if (items[y][x] == items[y][x-1]) {
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
					if (items[y][x] == items[y-1][x]) {
						// Two in a row
						tempMatch.push(new FlxPoint(x, y));
					} else if (tempMatch.length >= 3) {
						// this one doesn't match but it has 3 in it
						vMatches.push(tempMatch);
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

	public function isResovling():Bool {
		return resolvingMatches;	
	}
}
