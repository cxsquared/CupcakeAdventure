package components.items;

import components.DropItemComponent;
import inventory.Inventory.InventoryItem;
import components.ActorComponentTypes;
import inventory.InventorySprite;
import managers.GameData;
import flixel.FlxG;
import components.items.MixerComponent.Recipe;
import states.PlayState;
import haxe.Json;
import openfl.Assets;

class OvenComponent extends DropItemComponent {

	var recipeData:Array<Dynamic>;

	override public function init(Data:Dynamic):Bool {
		super.init(Data);

		recipeData = new Array<Dynamic>();

		var fileData =  Json.parse(Assets.getText(Reflect.field(Data, "recipes")));
		recipeData = Reflect.field(fileData, "recipes");

		return true;
	}

	override public function getComponentID():ActorComponentTypes {
		return ActorComponentTypes.OVEN;
	}

	override private function onDrop(Item:InventorySprite) {
		for (recipe in recipeData) {
			if (Item.inventoryData.Name == Reflect.field(recipe, "name")) {
				GameData.getInstance().heldItem = null;
				GameData.getInstance().saveCupcake(Reflect.field(recipe, "tags"));
				GameData.day++;
				FlxG.switchState(new PlayState());
			}
		}
	}

}