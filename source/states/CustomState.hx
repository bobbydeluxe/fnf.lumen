package states;

import psychlua.HScript;
import crowplexus.iris.Iris;
import backend.Song;
import backend.Highscore;
import options.OptionsState;
import mikolka.vslice.freeplay.FreeplayState;

#if HSCRIPT_ALLOWED
import crowplexus.iris.Iris;
import psychlua.HScript;
import bobbydx.HScriptVisuals;
#end

class CustomState extends MusicBeatState {

    var currentState = FlxG.save.data.currentState;

    var isScriptFinded:Bool = false;
    
	#if HSCRIPT_ALLOWED
	public var hscriptArray:Array<HScript> = [];
	public var hscriptObjects:Map<String, Dynamic> = new Map(); // add this at the top
	public var hscriptLayer:FlxSpriteGroup = new FlxSpriteGroup();
	#end

	public var visualUtils:HScriptVisuals;

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
				script.set("hxvisual", visualUtils);
				script.set("hscriptObjects", hscriptObjects);
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

		add(hscriptLayer); // <-- NEW: Add hscript visuals LAST so they render on top
    	visualUtils = new HScriptVisuals(hscriptLayer, hscriptObjects, callOnHScript); // <-- Pass hscriptLayer

        if (currentState == null) {
            currentState = "ErrorState";
        }

        #if HSCRIPT_ALLOWED
		//var scriptPath = Paths.getSharedPath() + 'data/haxescript/'+currentState+'.hx'; // Strict file path
		var scriptPath = Paths.getPath('data/haxescript/' + currentState + '.hx', TEXT, null, true);

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

    function triggerEvent(eventName:String,eventValue:Dynamic = 1,eventValue2:Dynamic = 1) {
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
				}
				else if (eventValue == "awards") {
					MusicBeatState.switchState(new AchievementsMenuState());
				}
				else if (eventValue == "mods") {
					MusicBeatState.switchState(new ModsMenuState());
                } else if (eventValue == "mainmenu") {
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
					PlayState.isStoryMode = false;
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