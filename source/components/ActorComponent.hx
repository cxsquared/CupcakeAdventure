package components;

import Actor;

interface ActorComponent {
	public var owner:Actor;

	public function init(Data:Dynamic):Bool;
	public function postInit():Void;
	public function update(DeltaTime:Float):Void;
	public function getComponentID():ActorComponentTypes;
	public function onAdd(Owner:Dynamic):Void; 
	public function onMouseEvent(e:MOUSEEVENT):Void;
	public function destroy():Void;
}