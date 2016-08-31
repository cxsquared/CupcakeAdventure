package components;

import flixel.text.FlxText;
import flixel.addons.text.FlxTextField;
import haxe.Json;
import openfl.Assets;
import actors.Actor;
import flixel.FlxG;
import managers.GameData;
import flixel.math.FlxRect;
import ibwwg.FlxScrollableArea;
import flixel.util.FlxColor;
import ibwwg.FlxScrollableArea.ResizeMode;
import flixel.FlxSprite;
import flixel.tweens.FlxTween;
import states.PlayState;
import managers.SceneManager;

typedef Message = {Name:String, Message:String};

class MessageComponent implements ActorComponent {

	public var owner:Actor;

	private var messageIndex = 0;

	private var nameTextSprite:FlxText;
	private var name_X = 60;
	private var name_Y = 15;
	private var name_width = 150;
	private var name_size = 16;
	private var messageTextSprite:FlxText;
	private var message_X = 60;
	private var message_Y = 60;
	private var message_size = 11;
	private var message_width = 225;
	private var message_height = 115;
	private var messageBackground:FlxSprite;

	private var scrollArea:FlxScrollableArea;

	private var messages:Array<Message>;
	
	public function init(Data:Dynamic):Bool {
		messages = new Array<Message>();
		var dayDataLocation = Reflect.field(Data, "messageData");
		var dayJson = Json.parse(Assets.getText(dayDataLocation));
		var dayData = Reflect.field(dayJson, "Day" + GameData.day);
		var messagesDataLocation = Reflect.field(dayData, GameData.getInstance().getCurrentDayName());
		var messagesDataJson = Json.parse(Assets.getText(messagesDataLocation));

		var messagesArray:Array<Dynamic> = Reflect.field(messagesDataJson, "messages");
		for (message in messagesArray) {
			var newMessage:Message = {Name:Reflect.field(message, "name"), Message:Reflect.field(message, "message")};
			messages.push(newMessage);
		}

		return true;
	}

	public function postInit():Void {
		nameTextSprite = new FlxText(name_X, name_Y, name_width, messages[0].Name, name_size);
		nameTextSprite.color = FlxColor.BLACK;
		var areaRect = new FlxRect(message_X, message_Y, message_width, message_height);
		messageTextSprite = new FlxText((FlxG.width*2) + message_X, message_Y, message_width-20, messages[0].Message, message_size);
		messageTextSprite.color = FlxColor.BLACK;
		var messageRect = new FlxRect(messageTextSprite.x, messageTextSprite.y, messageTextSprite.width, messageTextSprite.height);
		scrollArea = new FlxScrollableArea(areaRect, messageRect, ResizeMode.FIT_WIDTH, 5, FlxColor.CYAN, FlxG.state, 1);
		FlxG.cameras.add(scrollArea);
		scrollArea.setPosition(message_X, -FlxG.height+message_Y);

		messageBackground = new FlxSprite(messageTextSprite.x-10, messageTextSprite.y-10);
		messageBackground.makeGraphic(Std.int(messageTextSprite.width*2), Std.int(messageTextSprite.height+20)*2, new FlxColor(0xffc5e0dc));
	}

	public function updateText():Void {
		//TODO:Fix how scrollbar works
		nameTextSprite.text = messages[messageIndex].Name;
		messageTextSprite.text = messages[messageIndex].Message;

		if (messageTextSprite.height > messageBackground.height/2) {
			messageBackground.makeGraphic(Std.int(messageTextSprite.width*2), Std.int(messageTextSprite.height+20)*2, new FlxColor(0xffc5e0dc));
		}

		scrollArea.content.height = Math.max(messageTextSprite.height, message_height);
		scrollArea.onResize();
		scrollArea.scroll.y = message_Y;
	}

	public function update(DeltaTime:Float):Void {
	}

	public function getComponentID():ActorComponentTypes {
		return MESSAGES;
	}

	public function onAdd(Owner:Dynamic):Void {
		Owner.add(nameTextSprite);
		Owner.add(messageBackground);
		Owner.add(messageTextSprite);
	}

	public function nextMessage():Void {
		changeMessageIndex(1);
		updateText();
	}

	public function previousMessage():Void {
		changeMessageIndex(-1);
		updateText();
	}

	private function changeMessageIndex(amount:Int):Int {
		messageIndex += amount;
		if (messageIndex >= messages.length) {
			messageIndex = messageIndex%messages.length;
		} else if (messageIndex < 0) {
			messageIndex = messages.length + messageIndex%messages.length;
			if (messageIndex == 4) {
				messageIndex = 0;
			}
		}
		return messageIndex;
	}

	public function onMouseEvent(e:MOUSEEVENT):Void {
	}

	public function onEnter():Void {
		FlxTween.tween(scrollArea.viewPort, {x:message_X, y:message_Y}, .35, {onUpdate:onTweenUpdate, onComplete:onTweenComplete});
	}

	public function onExit():Void {
		FlxTween.tween(scrollArea.viewPort, {y:-FlxG.height+message_Y}, .25, {onUpdate:onTweenUpdate, onComplete:onTweenComplete});
	}

	public function destroy():Void {
	}

	public function onTweenUpdate(t:FlxTween):Void {
		scrollArea.onResize();
	}

	public function onTweenComplete(t:FlxTween):Void {
		scrollArea.onResize();
	}
}