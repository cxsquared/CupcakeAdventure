package components.matchthree;

import components.matchthree.MatchThreeController.MatchThreeItems;
import flixel.FlxG;
import flixel.util.FlxCollision;
import flixel.FlxObject;
import flixel.math.FlxPoint;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import actors.Actor;
import managers.SoundManager;

class MatchThreeItemComponent implements ActorComponent {

	public var owner:Actor;

	public var controller:MatchThreeController;
	public var gridX:Int;
	public var gridY:Int;
	public var itemType:MatchThreeItems;
	public var selected = false;

	private var dropping = false;

	private var dropSpeed = 0.55;
	private var dropSpeedOffset = 0.25; 

	private var switchSpeed = 0.25;

	private var clickPointOffset:FlxPoint;

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
			clickPointOffset = FlxPoint.weak(FlxG.mouse.x - owner.x, FlxG.mouse.y - owner.y);
			FlxG.log.add(itemType + " has been clicked at " + gridX + ":" + gridY);
		} else if (FlxG.mouse.justReleased) {
			selected = false;
		}

		if (!selected && !dropping) {
			var startingPoint = controller.getStartingPoint();
			owner.x = startingPoint.x + gridX * owner.width;
			owner.y = startingPoint.y + gridY * owner.height;
		} else if (selected && !dropping) {
			FlxG.watch.addQuick("X distance", Math.abs(FlxG.mouse.x - getGridMidPoint().x));
			if (Math.abs(FlxG.mouse.x - getGridMidPoint().x) > owner.width * .75 || 
				Math.abs(FlxG.mouse.y - getGridMidPoint().y) > owner.height * .75){
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
			} /*else {
				var side = getSelectSide();

				if (side == FlxObject.LEFT || side == FlxObject.RIGHT){
					owner.x = FlxG.mouse.x - clickPointOffset.x;
				} else {
					owner.y = FlxG.mouse.y - clickPointOffset.y;
				}
			}*/
		}
	}

	public function getComponentID():ActorComponentTypes {
		return ActorComponentTypes.MATCHTHREEITEM;
	}

	public function onAdd(Owner:Dynamic):Void {

	}

	public function destroy():Void {
		//clickPointOffset.destroy();
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
			case COCONUT:
				owner.loadGraphic("assets/images/match/match_coconutOil.png");
			case ALMOND:
			case VANILLA:
				owner.loadGraphic("assets/images/match/match_vanilla.png");
			case CHOCOLATE:
				owner.loadGraphic("assets/images/match/match_chocolate.png");
			case CARMEL:
				owner.loadGraphic("assets/images/match/match_carmel.png");
			case PUMPKIN:
			case SPICE:
			case CARROT:
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

	public function drop(startX:Float, startY:Float):Void {
		owner.x = startX;
		owner.y = startY;
		controller.numberOfItemsWaiting++;
		var newY = controller.getStartingPoint().y + gridY * owner.height;
		var tweenEase = FlxEase.bounceOut;
		if (startY < controller.getStartingPoint().y) {
			tweenEase = FlxEase.circOut;
		}
		FlxTween.tween(owner, {y:newY}, dropSpeed + (dropSpeed * FlxG.random.float(-dropSpeedOffset, dropSpeedOffset)),
		 { onComplete:doneDropping, ease:tweenEase });
		dropping = true;
	}

	private function doneDropping(t:FlxTween):Void {
		dropping = false;
		if(FlxG.random.bool(50) && t.ease == FlxEase.circOut) {
			SoundManager.GetInstance().playSound("matchfall", owner.x, owner.y);
		}
		controller.numberOfItemsWaiting--;
	}

	public function goToHome():Void {
		dropping = true;
		controller.numberOfItemsWaiting++;
		controller.numberOfItemsSwitching++;
		var startingPoint = controller.getStartingPoint();
		var newX = startingPoint.x + gridX * owner.width;
		var newY = startingPoint.y + gridY * owner.height;
		FlxTween.tween(owner, {x:newX, y:newY}, switchSpeed, { onComplete:homeTween, ease:FlxEase.elasticOut });
	}

	private function homeTween(t:FlxTween):Void {
		dropping = false;
		controller.numberOfItemsSwitching--;
		controller.numberOfItemsWaiting--;
	}

	private function getGridMidPoint():FlxPoint {
		var startingPoint = controller.getStartingPoint();
		var xMid = ((startingPoint.x + gridX * owner.width) + owner.width/2);
		var yMid = ((startingPoint.y + gridY * owner.height) + owner.height/2);
		return FlxPoint.weak(xMid, yMid);
	}

	public function removeActorAnimation(X:Int, Y:Int):Void {
		//FlxG.state.add(owner);
		dropping = true;
		FlxTween.tween(owner, {x:X, y:Y}, 0.5, {onComplete:destroyOwner});
		//FlxG.log.add("Tweening actor to " + X + ":" + Y);
	}

	private function destroyOwner(t:FlxTween):Void {
		owner.destroy();
	}

	public function onMouseEvent(e:MOUSEEVENT):Void{}

	public function onEnter():Void{
	}

	public function onExit():Void {
	}
}