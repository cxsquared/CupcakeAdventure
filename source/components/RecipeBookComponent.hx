package components;

import flixel.FlxG;

class RecipeBookComponent extends InteractableComponent {

	var currentPage = 0;
	var pages:Int = 3;

	override public function postInit(){
		owner.animation.callback = animCallback;
	}

	override private function onInteract():Void {
		if (currentPage == 0 && pages > 0) {
			owner.animation.play("open");
			currentPage++;
		} else {
			if (FlxG.mouse.x > FlxG.width/2) {
				if (pages >= currentPage+1) {
					currentPage++;
					owner.animation.play("page");
				}
			} else {
				if (currentPage > 1) {
					currentPage--;
					owner.animation.play("page", false, true);
				} else if (currentPage == 1) {
					currentPage--;
					owner.animation.play("open", false, true);
				}
			}
		}
	}

	private function animCallback(animName:String, frame:Int, index:Int):Void {

	}

	override public function getComponentID():ActorComponentTypes {
		return ActorComponentTypes.RECIPEBOOK;
	}
}