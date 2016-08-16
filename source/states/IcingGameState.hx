package states;

import flixel.FlxState;
import flixel.util.FlxColor;
import actors.*;

class IcingGameState extends FlxState {

	var color:FlxColor;

	public function new(cupCakeGraphic:Dynamic, icingColor:FlxColor) {
		super();

		color = icingColor;
	}

	override public function create():Void {
		super.create();

		var actor = ActorFactory.GetInstance().createActor({
			"name": "cupcake",
			"x": 65,
			"y": 50,
			"width": -1,
			"height": -1,
			"spriteSheet": "assets/images/icing/defaultCupcakeIce.png",
			"components": [
				{
					"name": "IcingBrushComponent",
					"data": {
						"color": {
							"r": color.red,
							"g": color.green,
							"b": color.blue
						}
					}
				}
			]
		});

		actor.addToState(this);
	}
 
	override public function update(elapsed:Float):Void {
		super.update(elapsed);
	}	
}