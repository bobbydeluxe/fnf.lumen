package states;

import psychlua.HScript;
import crowplexus.iris.Iris;

import backend.Song;
import backend.Highscore;
import options.OptionsState;
import mikolka.vslice.freeplay.FreeplayState;
import states.PlayState;

// This code is from Hybrid Engine, it was too good I added it to Lumen Engine
// Credits to SadeceNicat for the Hybrid Engine code

class CustomState extends MusicBeatState {

    var currentState = FlxG.save.data.currentState;

    var isScriptFinded:Bool = false;
    
	#if HSCRIPT_ALLOWED
	public var hscriptArray:Array<HScript> = [];
	#end

	#if (LUA_ALLOWED || HSCRIPT_ALLOWED)
	private var luaDebugGroup:FlxTypedGroup<psychlua.DebugLuaText>;
	#end

    public function callOnHScript(funcToCall:String, args:Array<Dynamic> = null) {
		#if HSCRIPT_ALLOWED
		for (script in hscriptArray) {
			if (script != null) {
				if (script.exists(funcToCall)) {
					script.call(funcToCall, args);
				}
			}
		}
		#end
	}

	public function initHScript(file:String)
	{
		var newScript:HScript = null;
		try
		{
			newScript = new HScript(null, file);
			if (newScript.exists('onCreate')) newScript.call('onCreate');
			trace('initialized hscript interp successfully: $file');
			hscriptArray.push(newScript);
		}
		catch(e:Dynamic)
		{
			addTextToDebug('ERROR ON LOADING ($file) - $e', FlxColor.RED);
			var newScript:HScript = cast (Iris.instances.get(file), HScript);
			if(newScript != null)
				newScript.destroy();
		}
	}

	#if (LUA_ALLOWED || HSCRIPT_ALLOWED)
	public function addTextToDebug(text:String, color:FlxColor) {

	}
	#end

    override function create() {
        super.create();

        if (currentState == null) {
            currentState = "ErrorState";
        }

        #if HSCRIPT_ALLOWED
		var scriptPath = Paths.getPath('scripts/registry/states/' + currentState + '.hx', TEXT, null, true);
		// this script path parodies the `data/registry` path, but in the scripts folder we have haxe script files instead of json files
		// if you were to make the code for your `JukeboxState` for example, you would place the file in `scripts/registry/states/JukeboxState.hx`

		if (FileSystem.exists(scriptPath)) {
		    initHScript(scriptPath);
		} else {
		    trace('HScript file not found: ' + scriptPath);
		}
		#end
    }

    override function update(elapsed:Float) {
        super.update(elapsed);

        if (isScriptFinded == false) {
            if (controls.BACK)
            {
                triggerEvent("ChangeState","mainmenu");
            }
        }
    }

    function triggerEvent(eventName:String,eventValue:Dynamic = 1,eventValue2:Dynamic = 1, songStoryMode:Bool = false)
	{
		switch (eventName) {
			case "ChangeState" :
				if (eventValue == "storymode") {
					MusicBeatState.switchState(new StoryMenuState());
				}
				else if (eventValue == "freeplay") {
					MusicBeatState.switchState(new FreeplayState());
				}
				else if (eventValue == "credits") {
					MusicBeatState.switchState(new CreditsState());
				}
				else if (eventValue == "options") {
					MusicBeatState.switchState(new OptionsState());
					OptionsState.onPlayState = false;
					if (PlayState.SONG != null)
					{
						PlayState.SONG.arrowSkin = null;
						PlayState.SONG.splashSkin = null;
						PlayState.stageUI = 'normal';
					}
				}
				else if (eventValue == "awards") {
					MusicBeatState.switchState(new AchievementsMenuState());
				}
				else if (eventValue == "mods") {
					MusicBeatState.switchState(new ModsMenuState());
				}
				else if (eventValue == "mainmenu") {
					MusicBeatState.switchState(new MainMenuState());
				} else {
					FlxG.save.data.currentState = eventValue;
					MusicBeatState.switchState(new CustomState());
				}
			case "LoadSong" :
				var songLowercase:String = Paths.formatToSongPath(eventValue);
				var poop:String = Highscore.formatSong(songLowercase, eventValue2);
	
				try
				{
					Song.loadFromJson(poop, songLowercase);
					PlayState.isStoryMode = songStoryMode;
					PlayState.storyDifficulty = eventValue2;
				}

				if (FlxG.save.data.isTransition == false) {
					MusicBeatState.switchState(new PlayState());
				} else {
					LoadingState.loadAndSwitchState(new PlayState());
				}
			default :
				trace("Null Value");
		}
	}
}