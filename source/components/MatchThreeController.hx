// MatchThreeController.hx -- Controls the match three mini-game items and flow
package components;

import flixel.FlxG;
import flixel.math.FlxPoint;

typedef MatchData = { 
	var location:FlxPoint;
	var dir:MatchDirection;
	var upLength:Int = 0;
	var downLength:Int = 0;
	var rightLength:Int = 0;
	var leftLength:Int = 0;
}

enum MatchDirection {
	HORIZONTAL;
	VERTICAL;
	TOP_RIGHT;
	TOP_LEFT;
	BOTTOM_RIGHT;
	BOTTOM_LEFT;
	CENTER;
}

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
	
	public function init(Data:Dynamic):Bool {

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

		for ( y in 0...5) {
			for ( x in 0...4) {
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
}