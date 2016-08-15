package components;

import inventory.*;
import inventory.Inventory.InventoryItem;
import openfl.Assets;
import haxe.Json;
import flixel.FlxG;
import managers.GameData;

typedef InventoryRecipe = { name:String, description:String, iconPath:String, ingredients:Array<String> };

class SaucePanComponent extends DropItemComponent {
	
	var items:Array<InventoryItem>;
	var recipes:Array<InventoryRecipe>;

	var possibleRecipes:Array<InventoryRecipe>;

	override public function init(Data:Dynamic):Bool {
		super.init(Data);

		items = new Array<InventoryItem>();
		recipes = new Array<InventoryRecipe>();
		possibleRecipes = new Array<InventoryRecipe>();

		var fileData =  Json.parse(Assets.getText(Reflect.field(Data, "recipes")));
		var recipeData:Array<Dynamic> = Reflect.field(fileData, "recipes");
		//FlxG.log.add(recipeData);
		for(recipe in recipeData) {
			parseRecipe(recipe);
		}

		return true;
	}

	private function parseRecipe(recipe:Dynamic):Void {
		var invenRecipe = { name:Reflect.field(recipe, "name"), description:Reflect.field(recipe, "description"),
			iconPath:Reflect.field(recipe, "icon"), ingredients:Reflect.field(recipe, "ingredients") };

		recipes.push(invenRecipe);
	}

	override public function getComponentID():ActorComponentTypes {
		return ActorComponentTypes.SAUCEPAN; // This number should never be refferenced
	}

	override private function onDrop(Item:InventorySprite) {
		var hasItem = false;
		for (item in items) {
			if (item.Name == Item.inventoryData.Name) {
				hasItem = true;
				break;
			}
		}

		if (hasItem) {
				owner.getTextComponent().say("I already put that in the mixer.");
		} else {
			if (inRecipe(Item.inventoryData.Name)) {
				owner.animation.play("cook");
				items.push(GameData.getInstance().inventory.getItem(Item.inventoryData.Name));
				GameData.getInstance().heldItem = null;
				checkRecipes();
			} else {
				owner.getTextComponent().say("I don't think that will work.");
			}
		}
	}

	private function inRecipe(itemName:String):Bool {
		if (possibleRecipes.length <= 0) {
			for (recipe in recipes) {
				for (item in recipe.ingredients) {
					if (item.toUpperCase() == itemName.toUpperCase()) {
						possibleRecipes.push(recipe);
						break;
					}
				}
			}

			if (possibleRecipes.length > 0) {
				return true;
			}
		} else {
			var hasItem = false;
			var noItem = new Array<InventoryRecipe>();
			for (recipe in possibleRecipes) {
				var itemInRecipe = false;
				for (item in recipe.ingredients) {
					if (item.toUpperCase() == itemName.toUpperCase()) {
						itemInRecipe = true;
						hasItem = true;
						break;
					}
				}
				if (!itemInRecipe) {
					noItem.push(recipe);
				}
			}

			if (hasItem) {
				for (recipe in noItem) {
					possibleRecipes.remove(recipe);
				}
				return true;
			}
		}

		return false;
	}

	private function checkRecipes():Void {
		for (recipe in possibleRecipes) {
			if (checkIngredients(recipe.ingredients)){
				var itemCheck = GameData.getInstance().inventory.getItem(recipe.name);
				if (itemCheck != null) {
					owner.getTextComponent().say("I don't need two of this.");
					GameData.getInstance().inventory.addItem(itemCheck);
				} else {
					//FlxG.log.add("New ingredient made " + recipe.name);
					GameData.getInstance().inventory.addNewItem(recipe.name, recipe.description, -1, recipe.iconPath);
				}

				possibleRecipes = new Array<InventoryRecipe>();
				items = new Array<InventoryItem>();

				InventoryUI.updateInventory = true;

				break;
			}
		}
	}

	private function checkIngredients(recipeIngredients:Array<String>):Bool {
		var numberOfMatches = 0;
		for (ingredient in recipeIngredients) {
			for (item in items) {
				if (ingredient.toUpperCase() == item.Name.toUpperCase()) {
					numberOfMatches++;
					break;
				}
			}
		}

		if (numberOfMatches == recipeIngredients.length) {
			return true;
		}

		return false;
	}
}