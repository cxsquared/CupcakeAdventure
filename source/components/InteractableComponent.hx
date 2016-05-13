package components;

class InteractableComponent implements ActorComponent {

	public var owner:Actor;
	
	public function init(Data:Dynamic):Bool {
		return true;
	}

	public function postInit(){
	}

	public function update(DeltaTime:Float) {
	}

	public function getComponentID():Int {
		return -1; // This number should never be refferenced
	}

	private function onInteract() {
	}
}