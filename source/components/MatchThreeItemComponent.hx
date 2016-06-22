package components;

import components.MatchThreeController.MatchThreeItems;
import flixel.FlxG;
import flixel.util.FlxCollision;

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
		if (FlxG.mouse.justPressed && !selected && FlxCollision.pixelPerfectPointCheck(FlxG.mouse.x, FlxG.mouse.y, owner)) {
			selected = true;
		} else if (!FlxCollision.pixelPerfectPointCheck(FlxG.mouse.x, FlxG.mouse.y, owner)) {
			selected = false;
		} else if (FlxG.mouse.justReleased) {
			selected = false;
		}

		if (!selected) {
			var startingPoint = controller.getStartingPoint();
			owner.x = startingPoint.x + gridX * owner.width;
			owner.y = startingPoint.y + gridY * owner.height;
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
}