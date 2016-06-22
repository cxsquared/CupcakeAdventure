package;

import flixel.FlxState;

class MatchThreeState extends FlxState {
	var actorFactory:ActorFactory;
	var inventoryUI:InventoryUI;

	override public function create():Void
	{
		super.create();

		actorFactory = new ActorFactory();

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
					"data": {}
				}
			]
		});

		add(actor);

	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
	}
}