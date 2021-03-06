package components.items;

import inventory.*;
import inventory.Inventory.InventoryItem;
import openfl.Assets;
import haxe.Json;
import managers.GameData;
import components.AnimationComponent;
import actors.Actor.MOUSEEVENT;

typedef InventoryRecipe = { name:String, description:String, iconPath:String, ingredients:Array<String> };

class SaucePanComponent extends DropItemComponent
{
    var items:Array<InventoryItem>;
    var recipes:Array<InventoryRecipe>;

    var possibleRecipes:Array<InventoryRecipe>;
    var animation:String = "";
    var animationController:AnimationComponent;

    var clicks = 0;

    override public function init(Data:Dynamic):Bool
    {
        super.init(Data);

        items = new Array<InventoryItem>();
        recipes = new Array<InventoryRecipe>();
        possibleRecipes = new Array<InventoryRecipe>();
        animation = Reflect.field(Data, "animation");

        var fileData = Json.parse(Assets.getText(Reflect.field(Data, "recipes")));
        var recipeData:Array<Dynamic> = Reflect.field(fileData, "recipes");

        for (recipe in recipeData)
        {
            parseRecipe(recipe);
        }

        return true;
    }

    override public function postInit():Void
    {
        animationController = cast(owner.getComponent(ActorComponentTypes.ANIMATION), AnimationComponent);
    }

    private function parseRecipe(recipe:Dynamic):Void
    {
        var invenRecipe = { name:Reflect.field(recipe, "name"), description:Reflect.field(recipe, "description"),
            iconPath:Reflect.field(recipe, "icon"), ingredients:Reflect.field(recipe, "ingredients") };

        recipes.push(invenRecipe);
    }

    override public function getComponentID():ActorComponentTypes
    {
        return ActorComponentTypes.SAUCEPAN;
    }

    override private function onDrop(Item:InventorySprite)
    {
        var hasItem = false;
        for (item in items)
        {
            if (item.Name == Item.inventoryData.Name)
            {
                hasItem = true;
                break;
            }
        }

        if (hasItem)
        {
            owner.getTextComponent().say("I already put that in the mixer.");
        }
        else
        {
            if (inRecipe(Item.inventoryData.Name))
            {
                animationController.ChangeAnimation(animation);
                items.push(GameData.getInstance().inventory.getItem(Item.inventoryData.Name));
                if (Item.inventoryData.Name == "coconut")
                {
                    GameData.getInstance().inventory.addItem(Item.inventoryData);

                }
                GameData.getInstance().heldItem.destroy();
                GameData.getInstance().heldItem = null;
                checkRecipes();
            }
            else
            {
                owner.getTextComponent().say("I don't think that will work.");
            }
        }
    }

    private function inRecipe(itemName:String):Bool
    {
        if (possibleRecipes.length <= 0)
        {
            for (recipe in recipes)
            {
                for (item in recipe.ingredients)
                {
                    if (item.toUpperCase() == itemName.toUpperCase())
                    {
                        possibleRecipes.push(recipe);
                        break;
                    }
                }
            }

            if (possibleRecipes.length > 0)
            {
                return true;
            }
        }
        else
        {
            var hasItem = false;
            var noItem = new Array<InventoryRecipe>();
            for (recipe in possibleRecipes)
            {
                var itemInRecipe = false;
                for (item in recipe.ingredients)
                {
                    if (item.toUpperCase() == itemName.toUpperCase())
                    {
                        itemInRecipe = true;
                        hasItem = true;
                        break;
                    }
                }
                if (!itemInRecipe)
                {
                    noItem.push(recipe);
                }
            }

            if (hasItem)
            {
                for (recipe in noItem)
                {
                    possibleRecipes.remove(recipe);
                }
                return true;
            }
        }

        return false;
    }

    private function checkRecipes():Void
    {
        for (recipe in possibleRecipes)
        {
            if (checkIngredients(recipe.ingredients))
            {
                var itemCheck = GameData.getInstance().inventory.getItem(recipe.name);
                if (itemCheck != null)
                {
                    owner.getTextComponent().say("I don't need two of this.");
                    GameData.getInstance().inventory.addItem(itemCheck);
                }
                else
                {
                    GameData.getInstance().removeTime(TimeActions.PICKUP);
                    owner.getTextComponent().say(recipe.description);
                    GameData.getInstance().inventory.addNewItem(recipe.name, recipe.description, -1, recipe.iconPath);
                }

                possibleRecipes = new Array<InventoryRecipe>();
                items = new Array<InventoryItem>();

                InventoryUI.updateInventory = true;

                break;
            }
        }
    }

    private function checkIngredients(recipeIngredients:Array<String>):Bool
    {
        var numberOfMatches = 0;
        for (ingredient in recipeIngredients)
        {
            for (item in items)
            {
                if (ingredient.toUpperCase() == item.Name.toUpperCase())
                {
                    numberOfMatches++;
                    break;
                }
            }
        }

        if (numberOfMatches == recipeIngredients.length)
        {
            return true;
        }

        return false;
    }

    override public function onMouseEvent(e:MOUSEEVENT):Void
    {
        super.onMouseEvent(e);
        if (e == MOUSEEVENT.DOWN)
        {
            if (clicks == 0 && items.length > 0)
            {
                clicks++;
                var outText = "Looks like I've added ";
                for (i in 0...items.length)
                {
                    if (i == items.length - 1)
                    {
                        if (items.length > 1)
                        {
                            outText += "and " + items[i].Name + ".";
                        }
                        else
                        {
                            outText += items[i].Name + ".";
                        }
                    }
                    else
                    {
                        outText += items[i].Name + " ";
                    }
                }
                owner.getTextComponent().say(outText);

            }
            else if (clicks == 1)
            {
                clicks++;
                owner.getTextComponent().say("Should I just start over?");
            }
            else if (items.length > 0)
            {
                owner.getTextComponent().say("I guess I'll start over...");
                items = new Array<InventoryItem>();
                clicks = 0;
            }
        }
    }
}