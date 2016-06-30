package;

import flixel.FlxState;
import components.MatchThreeController;
import components.MatchThreeController.MatchThreeItems;

class MatchThreeState extends FlxState {
	var actorFactory:ActorFactory;
	var inventoryUI:InventoryUI;

	var items:Array<String>;
	var maxScore:Int;
	var matchTime:Float;

	public function new(ingredients:Array<String>, timeLimit:Float, scoreLimit:Int){
		super();
		items = ingredients;
		matchTime = timeLimit;
		maxScore = scoreLimit;
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
						"score": maxScore,
						"time": matchTime
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