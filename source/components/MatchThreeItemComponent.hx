package components;

import components.MatchThreeController.MatchThreeItems;
import flixel.FlxG;
import flixel.util.FlxCollision;
import flixel.FlxObject;
import flixel.math.FlxPoint;

class MatchThreeItemComponent implements ActorComponent {

	public var owner:Actor;

	public var controller:MatchThreeController;
	public var gridX:Int;
	public var gridY:Int;
	public var itemType:MatchThreeItems;
	public var selected = false;

	public function init(Data:Dynamic):Bool {
		gridX = Reflect.field(Data, "x");
		gridY = Reflect.field(Data, "y");
		itemType = MatchThreeController.itemTypeFromString(Reflect.field(Data, "type"));
		return true;
	}

	public function postInit():Void {
		generateImage();
	}

	public function update(DeltaTime:Float):Void {
		if (FlxG.mouse.justPressed && !selected && !controller.isResovling() && FlxCollision.pixelPerfectPointCheck(FlxG.mouse.x, FlxG.mouse.y, owner)) {
			selected = true;
			FlxG.log.add(itemType + " has been clicked at " + gridX + ":" + gridY);
		} else if (FlxG.mouse.justReleased) {
			selected = false;
		}

		if (!selected) {
			var startingPoint = controller.getStartingPoint();
			owner.x = startingPoint.x + gridX * owner.width;
			owner.y = startingPoint.y + gridY * owner.height;
		} else {
			FlxG.watch.addQuick("X distance", Math.abs(FlxG.mouse.x - owner.getMidpoint().x));
			if (Math.abs(FlxG.mouse.x - owner.getMidpoint().x) > owner.width * .75 || 
				Math.abs(FlxG.mouse.y - owner.getMidpoint().y) > owner.height * .75){
				var side = getSelectSide();

				if (side == FlxObject.LEFT){
					controller.switchItems(new FlxPoint(gridX, gridY), new FlxPoint(gridX-1, gridY));
				} else if (side == FlxObject.RIGHT) {
					controller.switchItems(new FlxPoint(gridX, gridY), new FlxPoint(gridX+1, gridY));
				} else if (side == FlxObject.CEILING) {
					controller.switchItems(new FlxPoint(gridX, gridY), new FlxPoint(gridX, gridY-1));
				} else if (side == FlxObject.FLOOR) {
					controller.switchItems(new FlxPoint(gridX, gridY), new FlxPoint(gridX, gridY+1));
				}

				selected = false;
			}
		}
	}

	public function getComponentID():ActorComponentTypes {
		return ActorComponentTypes.MATCHTHREEITEM;
	}

	public function onAdd(Owner:Dynamic):Void {

	}

	public function destroy():Void {

	}

	public function generateImage():Void {
		switch (itemType) {
			case FLOUR:
				owner.loadGraphic("assets/images/match/match_flour.png");
			case SUGAR:
				owner.loadGraphic("assets/images/match/match_sugar.png");
			case SALT:
				owner.loadGraphic("assets/images/match/match_salt.png");
			case MILK:
				owner.loadGraphic("assets/images/match/match_milk.png");
			case BUTTER:
				owner.loadGraphic("assets/images/match/match_butter.png");
			case NONE:
				FlxG.log.error("Match Three Component on actor " + owner.getID() + " doesn't have a type.");
		}
	}

	private function getSelectSide():Int {
		FlxG.log.add("Getting a side");

		if (FlxG.mouse.x > owner.x && FlxG.mouse.x < owner.x + owner.height) {
			if (FlxG.mouse.y < owner.getMidpoint().y) {
				FlxG.log.add(itemType + " at " + gridX + ":" + gridY + " is moving Up");
				return FlxObject.CEILING;
			} else {
				FlxG.log.add(itemType + " at " + gridX + ":" + gridY + " is moving Down");
				return FlxObject.FLOOR;
			}
		} else {
			// Means it's either left or right
			if (FlxG.mouse.x < owner.getMidpoint().x){
				FlxG.log.add(itemType + " at " + gridX + ":" + gridY + " is moving Left");
				return FlxObject.LEFT;
			} else {
				FlxG.log.add(itemType + " at " + gridX + ":" + gridY + " is moving Right");
				return FlxObject.RIGHT;
			}
		}

		return FlxObject.NONE;
	}
}