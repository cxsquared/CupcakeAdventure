// MatchThreeController.hx -- Controls the match three mini-game items and flow
package components;

import flixel.FlxG;
import flixel.math.FlxPoint;
import flixel.math.FlxRandom;

typedef MatchData = Array<FlxPoint>;

enum MatchThreeItems {
	FLOUR;
	SUGAR;
	SALT;
	MILK;
	BUTTER;
}

class MatchThreeController implements ActorComponent {

	public var owner:Actor;

	private var width = 5;
	private var height = 5;
	private var startingX = 86;
	private var startingY = 10;
	private var itemSize = 44;

	private var items:Array<Array<MatchThreeItems>>; // [Row][Column]
	private var matches:Array<MatchData>;

	private var rand:FlxRandom;
	
	public function init(Data:Dynamic):Bool {
		items = new Array<Array<MatchThreeItems>>();
		matches = new Array<MatchData>();
		rand = new FlxRandom();

		var itemTest = new Array<MatchThreeItems>();
		itemTest.push(FLOUR);
		itemTest.push(SUGAR);
		itemTest.push(SALT);
		itemTest.push(MILK);
		itemTest.push(BUTTER);
		generateBoard(itemTest);

		FlxG.log.add(items[0][0]);
		FlxG.log.add(items[width-1][height-1]);

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

		FlxG.watch.addQuick("Number of matches", matches.length);
	}

	public function getComponentID():ActorComponentTypes {
		return ActorComponentTypes.MATCHTHREE;
	}

	public function onAdd(Owner:Dynamic):Void {

	}

	public function destory():Void {
	}

	private function generateBoard(ingredientTypes:Array<MatchThreeItems>):Void {
		for (y in 0...height) {
			var row = new Array<MatchThreeItems>();
			for (x in 0...width) {
				row.push(ingredientTypes[rand.int(0, ingredientTypes.length - 1)]);			
			}
			items.push(row);
		}
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
					FlxG.log.add(items[y][x] + " is " + items[y][x-1] + " ? " + (items[y][x] == items[y][x-1]));
					if (items[y][x] == items[y][x-1]) {
						// Two in a row
						FlxG.log.add("Adding point " + x + ":" + y + " to temp array");
						tempMatch.push(new FlxPoint(x, y));
					} else if (tempMatch.length >= 3) {
						// this one doesn't match but it has 3 in it
						FlxG.log.add("Adding temp array to matches and nulling tempMatch");
						hMatches.push(tempMatch);
						tempMatch = new Array<FlxPoint>();
						tempMatch.push(new FlxPoint(x, y));
					} else {
						FlxG.log.add("Nulling temp match");
					// this one doesn't match and the temp array doesn't have 3
						tempMatch = new Array<FlxPoint>();
						tempMatch.push(new FlxPoint(x, y));
					}
				} else {
					// always add the first one
					FlxG.log.add("Adding first point " + x + ":" + y + " to temp array");
					tempMatch.push(new FlxPoint(x, y));
				}
			}
			if (tempMatch != null && tempMatch.length >= 3) {
				hMatches.push(tempMatch);
			}

			tempMatch = null;
		}

		FlxG.log.add(hMatches.length + " horizontal matches");
		for (match in hMatches) {
			FlxG.log.add("horizontal match " + match);
		}

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

		FlxG.log.add(vMatches.length + " vertical matches");
		for (match in vMatches) {
			FlxG.log.add("Vertical match " + match);
		}

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
}
