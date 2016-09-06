package inventory;

import flixel.FlxSprite;
import flixel.util.FlxCollision;
import flixel.FlxG;
import managers.GameData;
import flixel.input.mouse.FlxMouseEventManager;
import flixel.math.FlxPoint;
import flixel.text.FlxText;
import flixel.util.FlxTimer;

class InventorySprite extends FlxSprite {

	var held = false;
	var heldFrames = 0;
	var startClick:FlxPoint;
	var descriptionText:FlxText;
	var descriptionTimer:FlxTimer;

	public var inventoryData:Inventory.InventoryItem;

	override public function new():Void {
		super();

		FlxMouseEventManager.add(this, onClick, onRelease, null, null);
		//TODO: MAke text fancier
		descriptionText = new FlxText();
		descriptionTimer = new FlxTimer();
	}
	
	override public function update(elapsed:Float) {
		super.update(elapsed);

		/*
		if (FlxCollision.pixelPerfectPointCheck(FlxG.mouse.x, FlxG.mouse.y, this) && FlxG.mouse.justPressed) {
			held = true;
		}
		*/
		if (!held && GameData.getInstance().heldItem == this) {
			heldFrames++;
			if(heldFrames > 25) {
				FlxG.log.add("Reseting held");
				GameData.getInstance().heldItem = null;
			}
		}

		if (held && FlxG.mouse.pressed) {
			x = FlxG.mouse.x - this.width/2;
			y = FlxG.mouse.y - this.height/2;
			GameData.getInstance().heldItem = this;
		}
	}

	private function onClick(t:FlxSprite):Void {
		held = true;
		startClick = FlxG.mouse.getPosition();
		heldFrames = 0;
		FlxMouseEventManager.setObjectMouseChildren(this, true);
	}

	private function onRelease(t:FlxSprite):Void {
		var mousePosition = FlxG.mouse.getPosition();
		if (mousePosition.x > startClick.x - width/2 && mousePosition.x < startClick.x + width/2
			&& mousePosition.y > startClick.y - height/2 && mousePosition.y < startClick.y + height/2) {
			descriptionText.text = inventoryData.Description;
			descriptionText.x = Math.min(Math.max(startClick.x - descriptionText.width/2, 0), FlxG.width - descriptionText.width);
			descriptionText.y = startClick.y - descriptionText.height;
			FlxG.state.add(descriptionText);
			descriptionText.visible = true;
			descriptionTimer.start(1.5, onTimer, 1);
		}
		held = false;
		FlxMouseEventManager.setObjectMouseChildren(this, false);
	}

	private function onTimer(t:FlxTimer):Void {
		descriptionText.visible = false;
	}

}