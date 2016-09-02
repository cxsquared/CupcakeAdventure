package components.items;

import inventory.*;
import inventory.Inventory.InventoryItem;
import flixel.FlxG;
import flixel.util.FlxCollision;
import openfl.Assets;
import haxe.Json;
import managers.GameData;
import states.MatchThreeState;

typedef Recipe = { name:String, ingredients:Array<String>, time:Float, score:Int };

class MixerComponent extends DropItemComponent {

	var items:Array<InventoryItem>;
	var recipes:Array<Recipe>;

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

	private function parseRecipe(recipe:Dynamic):Void {
		var newRecipe:Recipe = { name:Reflect.field(recipe, "name"), ingredients:Reflect.field(recipe, "ingredients"),
								time:Reflect.field(recipe, "time"), score:Reflect.field(recipe, "score")};
		//FlxG.log.add(newRecipe);
		recipes.push(newRecipe);
	}

	override public function getComponentID():ActorComponentTypes {
		return ActorComponentTypes.MIXER; // This number should never be refferenced
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
				var textComp = cast(owner.getComponent(ActorComponentTypes.DESCRIPTION), DescriptionComponent);
				if (textComp == null) {
					var tempComp:DescriptionComponent = Type.createInstance(DescriptionComponent, []);
					tempComp.init({
						"description": "I already put that in the mixer",
						"color": {
							"r": FlxG.random.color().red,
							"g": FlxG.random.color().green,
							"b": FlxG.random.color().blue
						}
					});
					textComp = cast(owner.addComponent(tempComp), DescriptionComponent);
					textComp.postInit();
				}

				textComp = cast(textComp, DescriptionComponent);
				textComp.say("I already put that in the mixer.");
		} else {
			owner.animation.play("mix");
			items.push(GameData.getInstance().inventory.getItem(Item.inventoryData.Name));
			GameData.getInstance().heldItem = null;
			checkRecipes();
		}
	}

	private function checkRecipes():Void {
		for (recipe in recipes) {
			if (checkIngredients(recipe.ingredients)){
				FlxG.switchState(new MatchThreeState(recipe.ingredients, recipe.time, recipe.score));
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
	
}