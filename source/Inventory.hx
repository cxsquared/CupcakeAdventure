package;

typedef InventoryItem = { Name:String, Description:String, ActorID:Int, IconPath:String };

class Inventory {
	
	var inventoryItems:Map<String,InventoryItem>;

	public function new():Void {
		init();
	}

	private function init():Void {
		inventoryItems = new Map<String,InventoryItem>();
	}

	public function addNewItem(Name:String, Description:String, ActorID:Int, IconPath:String):Void {
		var item = { Name:Name, Description:Description, ActorID:ActorID, IconPath:IconPath };
		addItem(item);
	}

	public function addItem(Item:Inventory.InventoryItem):Void {
		inventoryItems.set(Item.Name, Item);
	}

	// Can return null if item doesn't exist
	public function getItem(Name:String):InventoryItem {
		if (inventoryItems.exists(Name)) {
			return inventoryItems.get(Name);
		}

		return null;
	}

	public function getAllItems():Array<InventoryItem> {
		var inventoryArray:Array<InventoryItem> = new Array<InventoryItem>();

		for (item in inventoryItems) {
			inventoryArray.push(item);
		}

		return inventoryArray;
	}
}