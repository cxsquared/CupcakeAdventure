// MatchThreeController.hx -- Controls the match three mini-game items and flow
package components;

import flixel.FlxG;
import flixel.math.FlxPoint;

typedef MatchData = Array<FlxPoint>;

enum MatchThreeItems {
	FLOUR;
	SUGAR;
	SALT;
	MILK;
	BUTTER;
}

class MatchThreeController extends ActorComponent {

	public var owner:Actor;

	private var width = 5;
	private var height = 5;
	private var startingX = 86;
	private var startingY = 10;
	private var itemSize = 44;

	private var items:Array<Array<MatchThreeItems>>; // [Row][Column]
	private var matches:Array<MatchData>;
	
	public function init(Data:Dynamic):Bool {
		items = new Array<Array<MatchThreeItems>>();
		matches = new Array<MatchData>();

	}

	public function postInit():Void {

	}

	public function update(DeltaTime:Float):Void {

	}

	public function getComponentID():ActorComponentTypes {

	}

	public function onAdd(Owner:Dynamic):Void {

	}

	public function destory():Void {

	}

	private function generateBoard(ingredientTypes:Array<MatchThreeItems>):Void {
		
	}

	private function checkForAllMatchs():Array<MatchData> {
		var matches = new Array<MatchData>();

		var currentStart:FlxPoint = null;
		var rightLength:Int = 0;
		var leftLength:Int = 0;
		var upLength:Int = 0;
		var downLength:Int = 0;

		for ( y in 0...height) {
			for ( x in 0...) {
				if (currentStart != null || (x < 3)) {
					// Horivontal check
					if (items[x][y] == items[x+1][y]){
						// Next Item matches
						if (currentStart == null) {
							// new start point
							currentStart = new FlxPoint(x, y);
							rightLength++;
						} else {
							// extend length
							rightLength++;
						}
					} else if (rightLength < 3){
						// Items don't match and isn't long enough
						rightLength = 0;
						currentStart = null;
					}
				}
			}
			
		}
	}

	private function checkItem(X:Int, Y:Int):Bool {
		// Horizontal
		if (X < width - 2) {
			var hMatch = new MatchData();
			hMatch.add(new FlxPoint(X, Y));
			for ( x in X+1...width) {
				if (items[X][Y] == items[x][Y]) {
					hMatch.add( new FlxPoint(x, Y));
				} else if (hMatch.length() > 2) {
					break;
				} else {
					hMatch = null;
				}
			}
		}

		if (hMatch != null) {
			var vMatch = new MatchData();
			for (y in Y-1...0) {
				if (y >= 0 && items[X][Y] == items[X][y] && items[X][y]) {
					vMatch.add(new FlxPoint(X, y));
				} else {
					break;
				}
			}
		}

		var vLength = 0;

		// Vertical
		if (Y < height - 2) {
			for ( y in Y+1...height) {
				if (items[X][Y] == items[X][y]) {
					vLength++;
				} else if (vLength < 3 || items[X])
			}
		}
		
	}
}