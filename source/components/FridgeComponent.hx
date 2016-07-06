package components;

import flixel.FlxG;

class FridgeComponent extends InteractableComponent {

	var topOpen:Bool = false;
	var bottomOpen:Bool = false;

	var doorCutOff = 81;

	var topNotes:Array<Actor>;
	var bottomNotes:Array<Actor>;

	override public function init(Data:Dynamic):Bool {
		super.init(Data);
		//SoundManager.GetInstance().loadSounds(AssetPaths.CabinetSounds__json);
		return true;
	}

	override public function postInit(){
		super.postInit();
	}

	override public function update(DeltaTime:Float) {
		//FlxG.watch.addQuick("left open", leftOpen);
		//FlxG.watch.addQuick("right open", rightOpen);
		super.update(DeltaTime);
	}

	override public function getComponentID():ActorComponentTypes {
		return ActorComponentTypes.FRIDGE; // This number should never be refferenced
	}

	override private function onInteract():Void {
		if (FlxG.mouse.y < owner.y + doorCutOff) {
			topClicked();
		} else {
			bottomClicked();
		}
	}

	private function topClicked():Void {
		if (topOpen) {
			topOpen = false;
			FlxG.sound.play(AssetPaths.closeCabinet__wav);
			if (bottomOpen) {
				owner.animation.play("topAfterBottom", false, true);
				updateNotes(true, false);
			} else {
				owner.animation.play("topOnly", false,  true);
				updateNotes(true, true);
			}
		} else {
			FlxG.sound.play(AssetPaths.openCabinet__wav);
			topOpen = true;
			if (bottomOpen) {
				owner.animation.play("topAfterBottom", false);
				updateNotes(false, false);
			} else {
				owner.animation.play("topOnly", false);
				updateNotes(false, true);
			}
		}
	}

	private function bottomClicked():Void {
		//FlxG.log.add("Right Clicked");
		if (bottomOpen) {
			bottomOpen = false;
			FlxG.sound.play(AssetPaths.closeCabinet__wav);
			if (topOpen) {
				owner.animation.play("bottomAfterTop", false, true);
				updateNotes(false, true);
			} else {
				owner.animation.play("bottomOnly", false, true);
				updateNotes(true, true);
			}
		} else {
			bottomOpen = true;
			FlxG.sound.play(AssetPaths.openCabinet__wav);
			if (topOpen) {
				owner.animation.play("bottomAfterTop", false);
				updateNotes(false, false);
			} else {
				owner.animation.play("bottomOnly", false);
				updateNotes(true, false);
			}
		}
	}

	private function updateNotes(showTop:Bool, showBottom:Bool):Void {
		findNotes();

		FlxG.watch.addQuick("TopNotes", topNotes);
		FlxG.watch.addQuick("BottomNotes", bottomNotes);

		for (note in topNotes) {
			note.alpha = showTop ? 1 : 0;
		}

		for (note in bottomNotes) {
			note.alpha = showBottom ? 1 : 0;
			FlxG.log.add("Setting actor " + note.getID() + " to " + showBottom);
		}
	}

	private function findNotes():Void {
		if (topNotes == null || bottomNotes == null) {
			topNotes = new Array<Actor>();
			bottomNotes = new Array<Actor>();
			var actors = SceneManager.GetInstance().getActorsInScene();

			for (actor in actors) {
				if (actor.hasComponent(ActorComponentTypes.LETTER) && FlxG.overlap(actor, owner)) {
					if (actor.y < owner.y + doorCutOff) {
						topNotes.push(actor);
					} else {
						bottomNotes.push(actor);
					}
				}
			}
		}
	}
}