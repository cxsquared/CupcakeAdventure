package managers;

import flixel.system.FlxSound;
import haxe.Json;
import flixel.FlxG;
import openfl.Assets;
import managers.GameData;

typedef MusicData = { sound:FlxSound, volume:Float }

class SoundManager
{

    private static var instance:SoundManager;

    var soundsMap:Map<String, FlxSound>;
    var musicMap:Map<String, MusicData>;

    var currentMusic:FlxSound;

    public static function GetInstance():SoundManager
    {
        if (instance != null)
        {
            return instance;
        }

        var sm = new SoundManager();
        SoundManager.instance = sm;
        return instance;
    }

    private function new()
    {
        soundsMap = new Map<String, FlxSound>();
        musicMap = new Map<String, MusicData>();
    }

    public function loadSounds(JSONDataPath:String):Void
    {
        currentMusic = null;
        for (sound in soundsMap)
        {
            sound.destroy();
        }

        for (music in musicMap)
        {
            music.sound.destroy();
        }

        soundsMap = new Map<String, FlxSound>();
        musicMap = new Map<String, MusicData>();

        var jsData = Json.parse(Assets.getText(JSONDataPath));

        if (Reflect.hasField(jsData, "sounds"))
        {
            var soundData:Array<Dynamic> = Reflect.field(jsData, "sounds");

            for (sound in soundData)
            {
                var s = new FlxSound();
                FlxG.log.add("loading sound " + Reflect.field(sound, "name"));
                s.loadEmbedded("assets/sounds/" + Reflect.field(sound, "name") + ".wav", Reflect.field(sound, "looped"), false);
                s.volume = Reflect.field(sound, "volume");
                soundsMap.set(Reflect.field(sound, "name"), s);
                FlxG.state.add(s);
            }
        }

        if (Reflect.hasField(jsData, "music"))
        {
            var musicData:Array<Dynamic> = Reflect.field(jsData, "music");

            for (music in musicData)
            {
                var s = new FlxSound();
                FlxG.log.add("loading music " + Reflect.field(music, "name"));
                s.loadEmbedded("assets/sounds/music/" + Reflect.field(music, "name") + ".mp3", true, false);
                s.volume = 0;
                musicMap.set(Reflect.field(music, "name"), {sound:s, volume:Reflect.field(music, "volume")});
                FlxG.state.add(s);
            }
        }
    }

    public function playSound(Name:String, X:Float = -1, Y:Float = -1):FlxSound
    {
        if (X < 0)
        {
            X = FlxG.width / 2;
        }
        if (Y < 0)
        {
            Y = FlxG.height / 2;
        }

        if (soundsMap.exists(Name))
        {
            if (soundsMap.get(Name).playing)
            {
                return FlxG.sound.play("assets/sounds/" + Name + ".wav").proximity(X, Y, GameData.getInstance().player, FlxG.width * .75, true);
            }
            else
            {
                return soundsMap.get(Name).play(true).proximity(X, Y, GameData.getInstance().player, FlxG.width * .75, true);
            }
        }
        else
        {
            FlxG.log.error("The sound " + Name + " isn't loaded in game.");
        }

        return null;
    }

    public function stopSound(Name:String):FlxSound
    {
        if (soundsMap.exists(Name))
        {
            return soundsMap.get(Name).stop();
        }
        else
        {
            FlxG.log.error("The sound " + Name + " isn't loaded in game.");
        }

        return null;
    }

    public function playMusic(Name:String):FlxSound
    {
        if (musicMap.exists(Name))
        {
            if (currentMusic != null)
            {
                currentMusic.fadeOut();
            }
            currentMusic = musicMap.get(Name).sound;
            currentMusic.fadeIn(1, 0, musicMap.get(Name).volume);
            return currentMusic;
        }
        else
        {
            FlxG.log.error("The music " + Name + " isn't loaded in game.");
        }

        return null;
    }

    public function stopMusic():Void
    {
        if (currentMusic != null)
        {
            currentMusic.fadeOut();
        }
    }
}