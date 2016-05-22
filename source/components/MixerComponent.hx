package components;

import Inventory.InventoryItem;
import flixel.FlxG;

class MixerComponent extends DropItemComponent {

	var items:Array<InventoryItem>;

	override public function init(Data:Dynamic):Bool {
		super.init(Data);

		items = new Array<InventoryItem>();

		return true;
	}

	override public function postInit(){
	}

	override public function update(DeltaTime:Float) {
		super.update(DeltaTime);

		FlxG.watch.addQuick("Mixer items", items.length);
	}

	override public function getComponentID():ActorComponentTypes {
		return ActorComponentTypes.MIXER; // This number should never be refferenced
	}

	override private function onDrop(Item:InventorySprite) {
		items.push(GameData.getInstance().inventory.getItem(Item.inventoryData.Name));
	}
	
}