package components;

class MatchThreeItemComponent implements ActorComponent {

	public var owner:Actor;

	public function init(Data:Dynamic):Bool {
		return true;
	}

	public function postInit():Void {

	}

	public function update(DeltaTime:Float):Void {

	}

	public function getComponentID():ActorComponentTypes {
		return ActorComponentTypes.MATCHTHREEITEM;
	}

	public function onAdd(Owner:Dynamic):Void {

	}

	public function destory():Void {

	}
}