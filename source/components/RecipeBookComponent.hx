package components;

import flixel.FlxG;
import flixel.math.FlxPoint;
import flixel.group.FlxSpriteGroup;
import haxe.Json;
import openfl.Assets;
import flixel.text.FlxText;
import flixel.FlxSprite;
import flixel.tweens.FlxTween;

class RecipeBookComponent extends InteractableComponent {

	var currentPage = 0;
	var pages:Int = 1;

	var recipePages:Array<FlxSpriteGroup>;

	var cupcakeImageLocation = new  FlxPoint(61, 55);

	var fadeTime = .35;

	override public function init(Data:Dynamic):Bool {
		super.init(Data);
		recipePages = new Array<FlxSpriteGroup>();

		var recipesJson = Json.parse(Assets.getText(Reflect.field(Data, "recipes")));
		var recipes:Array<Dynamic> = Reflect.field(recipesJson, "recipes");

		for (recipe in recipes) {
			parseRecipe(recipe);
		}

		pages = Math.ceil(recipePages.length/2);

		return true;
	}

	override public function postInit(){
		super.postInit();
		owner.animation.callback = animCallback;
	}

	override public function onAdd(Owner:Dynamic):Void {
		super.onAdd(Owner);
		for (page in recipePages) {
			Owner.add(page);
		}
	}

	private function parseRecipe(recipe:Dynamic):Void {
		var recipeHolder = new FlxSpriteGroup();

		var titlePadding = 5;
		var title = new FlxText();
		title.size = 9;
		title.text = Reflect.field(recipe, "name");
		recipeHolder.add(title);

		var cupcake = new FlxSprite();
		cupcake.loadGraphic(Reflect.field(recipe, "cupcake"));
		recipeHolder.add(cupcake);

		var ingredientsData:Array<String> = Reflect.field(recipe, "ingredients");
		var ingredientsText = new FlxText();
		ingredientsText.height = ingredientsData.length * ingredientsText.height;
		for (ingredient in ingredientsData) {
			ingredientsText.text += ingredient + "\n";
		}
		recipeHolder.add(ingredientsText);

		title.y =  cupcakeImageLocation.y - title.height - titlePadding;
		cupcake.y = cupcakeImageLocation.y;
		ingredientsText.y = cupcakeImageLocation.y + cupcake.height + titlePadding;

		if (recipePages.length % 2 == 0) {
			// Left
			title.x = FlxG.width/4 - title.width/2;
			cupcake.x = cupcakeImageLocation.x;
			ingredientsText.x = cupcakeImageLocation.x;
		} else {
			// right
			title.x = FlxG.width*.75 - title.width/2;
			cupcake.x = FlxG.width - cupcakeImageLocation.x - cupcake.width;
			cupcake.flipX = true;
			ingredientsText.x = FlxG.width - cupcakeImageLocation.x - cupcake.width;
		}

		recipeHolder.alpha = 0;
		recipePages.push(recipeHolder);
	}

	override private function onInteract():Void {
		if (currentPage == 0 && pages > 0) {
			open();
		} else {
			if (FlxG.mouse.x > FlxG.width/2) {
				flipPage(false);
			} else {
				flipPage(true);
			}
		}
	}

	private function flipPage(left:Bool):Void {
		if (left) {
			if (currentPage > 1) {
				currentPage--;
				owner.animation.play("page", false, true);
				var startingViewPage = currentPage*2-2;
				if (recipePages.length-1 >= startingViewPage+3){
					tweenRecipe(startingViewPage+3, false);
					tweenRecipe(startingViewPage+2, false);
				} else if (recipePages.length-1 >= startingViewPage+2) {
					tweenRecipe(startingViewPage+2, false);
				}

				if (recipePages.length-1 >= startingViewPage+1) {
					tweenRecipe(startingViewPage+1, true);
					tweenRecipe(startingViewPage, true);
				} else if (recipePages.length-1 >= startingViewPage) {
					tweenRecipe(startingViewPage, true);
				}
			} else if (currentPage == 1) {
				close();
			}
		} else {
			if (pages >= currentPage+1) {
				currentPage++;
				owner.animation.play("page");
				var startingViewPage = currentPage*2-2;
				
				tweenRecipe(startingViewPage-2, false);
				tweenRecipe(startingViewPage-1, false);

				if (recipePages.length-1 >= startingViewPage+1) {
					tweenRecipe(startingViewPage+1, true);
				}

				tweenRecipe(startingViewPage, true);
			}
		}
	}

	private  function close():Void {
		owner.animation.play("open", false, true);
		currentPage = 0;
		if (recipePages.length > 1) {
			tweenRecipe(0, false);
			tweenRecipe(1, false);
		} else if (recipePages.length > 0) {
			tweenRecipe(0, false);
		}
	}

	private function open():Void {
		owner.animation.play("open");
		currentPage = 1;
		if (recipePages.length > 1) {
			tweenRecipe(0, true);
			tweenRecipe(1, true);
		} else if (recipePages.length > 0) {
			tweenRecipe(0, true);
		}
	}

	private function tweenRecipe(pageIndex:Int, fadeIn:Bool):Void {
		var newAlpha = fadeIn ? 1 : 0;
		for (page in recipePages[pageIndex]) {
			FlxTween.tween(page, {alpha:newAlpha}, fadeTime);
		}
	}

	private function animCallback(animName:String, frame:Int, index:Int):Void {

	}

	override public function getComponentID():ActorComponentTypes {
		return ActorComponentTypes.RECIPEBOOK;
	}

	override public function destroy():Void {
		for (page in recipePages) {
			page.destroy();
		}

		recipePages.splice(0, recipePages.length);

		super.destroy();
	}
}