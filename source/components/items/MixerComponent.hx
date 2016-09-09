package components.items;

import inventory.*;
import inventory.Inventory.InventoryItem;
import flixel.FlxG;
import flixel.util.FlxCollision;
import openfl.Assets;
import haxe.Json;
import managers.GameData;
import states.MatchThreeState;
import actors.Actor.MOUSEEVENT;

typedef Recipe = { name:String, ingredients:Array<String>, moves:Float, maxscore:Int, minscore:Int };

class MixerComponent extends DropItemComponent {

	var items:Array<InventoryItem>;
	var recipes:Array<Recipe>;

	var clicks = 0;

	override public function init(Data:Dynamic):Bool {
		super.init(Data);

		items = new Array<InventoryItem>();
		recipes = new Array<Recipe>();

		var fileData =  Json.parse(Assets.getText(Reflect.field(Data, "recipes")));
		var recipeData:Array<Dynamic> = Reflect.field(fileData, "recipes");
		//FlxG.log.add(recipeData);
		for(recipe in recipeData) {
			parseRecipe(recipe);
		}

		return true;
	}

	override public function postInit():Void {
		var oldItems:Array<InventoryItem> = GameData.getInstance().getData(GameData.day, "mixer" + owner.getID());
		if (oldItems != null) {
			for (item in oldItems) {
				items.push(item);
			}
		}
	}

	private function parseRecipe(recipe:Dynamic):Void {
		var newRecipe:Recipe = { name:Reflect.field(recipe, "name"), ingredients:Reflect.field(recipe, "ingredients"),
								moves:Reflect.field(recipe, "moves"), maxscore:Reflect.field(recipe, "maxscore"), minscore:Reflect.field(recipe, "minscore")};
		//FlxG.log.add(newRecipe);
		recipes.push(newRecipe);
	}

	override public function getComponentID():ActorComponentTypes {
		return ActorComponentTypes.MIXER; // This number should never be refferenced
	}

	override private function onDrop(Item:InventorySprite) {
		clicks = 0;
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
			owner.animation.play("mix");
			items.push(GameData.getInstance().inventory.getItem(Item.inventoryData.Name));
			GameData.getInstance().heldItem.destroy();
			GameData.getInstance().heldItem = null;
			GameData.getInstance().saveData(GameData.day, "mixer" + owner.getID(), items);
			checkRecipes();
		}
	}

	private function checkRecipes():Void {
		for (recipe in recipes) {
			if (checkIngredients(recipe.ingredients)){
				GameData.getInstance().saveData(GameData.day, "mixer" + owner.getID(), []);
				GameData.getInstance().removeTime(TimeActions.MIX);
				FlxG.switchState(new MatchThreeState(recipe.name, recipe.ingredients, recipe.moves, recipe.maxscore, recipe.minscore));
			}
		}
	}

	private function checkIngredients(recipeIngredients:Array<String>):Bool {
		var numberOfMatches = 0;
		for (ingredient in recipeIngredients) {
			for (item in items) {
				if (ingredient == item.Name) {
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

	override public function onMouseEvent(e:MOUSEEVENT):Void {
		super.onMouseEvent(e);
		if (e == MOUSEEVENT.DOWN) {
			if (items.length <= 0) {
				owner.getTextComponent().say("I should put ingredients in there.");
			}
			else if (clicks == 0) {
				clicks++;
				var outText = "Looks like I've added ";
				for (i in 0...items.length) {
					if (i == items.length - 1){
						if (items.length > 1) {
							outText += "and " + items[i].Name + ".";
						} else {
							outText += items[i].Name + ".";
						}
					} else {
						outText += items[i].Name + " ";
					}
				}
				owner.getTextComponent().say(outText);

			} else if (clicks == 1) {
				clicks++;
				owner.getTextComponent().say("Should I just start over?");
			} else {
				owner.getTextComponent().say("I guess I'll start over...");
				items = new Array<InventoryItem>();
				clicks = 0;
			}
		}
	}
	
}