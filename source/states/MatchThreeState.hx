package states;

import flixel.FlxState;
import components.matchthree.MatchThreeController;
import components.matchthree.MatchThreeController.MatchThreeItems;
import actors.ActorFactory;
import inventory.InventoryUI;

class MatchThreeState extends FlxState {
	var actorFactory:ActorFactory;
	var inventoryUI:InventoryUI;

	var items:Array<String>;
	var maxScore:Int;
	var minScore:Int;
	var moves:Float;
	var cupcake:String;

	public function new(Cupcake:String, ingredients:Array<String>, moveLimit:Float, maxScore:Int, minScore:Int){
		super();
		this.items = ingredients;
		this.moves = moveLimit;
		this.maxScore = maxScore;
		this.minScore = minScore;
		this.cupcake = Cupcake;
	}

	override public function create():Void
	{
		super.create();

		actorFactory = ActorFactory.GetInstance();

		var actor = actorFactory.createActor({
			"name": "manager",
			"x": 0,
			"y": 0,
			"width": -1,
			"height": -1,
			"spriteSheet": "assets/images/match/match_background.png",
			"components": [
				{
					"name": "MatchThreeController",
					"data": {
						"items": items,
						"maxscore": maxScore,
						"minscore": minScore,
						"moves": moves,
						"cupcake": cupcake
					}
				}
			]
		});

		actor.addToState(this);

	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
	}
}