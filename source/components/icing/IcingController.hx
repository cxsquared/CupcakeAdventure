package components.icing;

import actors.*;

class IcingController implements ActorComponent {
	public var owner:Actor;
	
	public function init(Data:Dynamic):Bool {

		return true;
	}

	public function postInit():Void {

	}

	public function update(DeltaTime:Float):Void {

	}

	public function getComponentID():ActorComponentTypes {
		return ICINGCONTROLLER;
	}

	public function onAdd(Owner:Dynamic):Void {

	}

	public function onMouseEvent(e:MOUSEEVENT):Void {

	}

	public function onEnter():Void {

	}

	public function onExit():Void {

	}

	public function destroy():Void {

	}
}