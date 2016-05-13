package components;

import Actor;

interface ActorComponent {
	public var owner:Actor;

	public function init(Data:String):Bool;
	public function postInit():Void;
	public function update(DeltaTime:Float):Void;
	public function getComponentID():Int;
}