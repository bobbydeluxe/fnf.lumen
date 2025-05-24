package states;

import psychlua.HScript;
import crowplexus.iris.Iris;

import backend.Song;
import backend.Highscore;
import options.OptionsState;
import mikolka.vslice.freeplay.FreeplayState;
import states.PlayState;
import misc.CustomMainMenuConfig;
import substates.StickerSubState;
import mikolka.compatibility.ModsHelper;

// This code is from Hybrid Engine, it was too good I added it to Lumen Engine
// Credits to SadeceNicat for the Hybrid Engine code

class CustomState extends MusicBeatState {

    var currentState = FlxG.save.data.currentState;
    
	#if HSCRIPT_ALLOWED
	public var hscriptArray:Array<HScript> = [];
	#end

	#if (LUA_ALLOWED || HSCRIPT_ALLOWED)
	private var luaDebugGroup:FlxTypedGroup<psychlua.DebugLuaText>;
	#end

	var stickerSubState:StickerSubState;
	public function new(?stickers:StickerSubState = null, isDisplayingRank:Bool = false)
	{
		super();

		if (stickers != null)
		{
			stickerSubState = stickers;
		}
	}

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

		Paths.clearUnusedMemory();

		if (stickerSubState != null)
		{
		  callOnHScript("onStickerTrans", []);
		  //this.persistentUpdate = true;
		  //this.persistentDraw = true
		  openSubState(stickerSubState);
		  ModsHelper.clearStoredWithoutStickers();
		  stickerSubState.degenStickers();
		  callOnHScript("onStickerTransPost", []);
		}

        super.create();

        if (currentState == null) {
            currentState = "ErrorState";
        }

        #if HSCRIPT_ALLOWED
		for (folder in Mods.directoriesWithFile(Paths.getSharedPath(), 'scripts/states/custom/' + currentState + '/'))
			for (file in FileSystem.readDirectory(folder))
			{

				#if HSCRIPT_ALLOWED
				if(file.toLowerCase().endsWith('.hx'))
					initHScript(folder + file);
				#end
			}
		#end
    }

    override function update(elapsed:Float) {
		callOnHScript("onUpdate", [elapsed]);
        super.update(elapsed);
		callOnHScript("onUpdatePost", [elapsed]);
    }

    function triggerEvent(eventName:String,eventValue:Dynamic = 1,eventValue2:Dynamic = 1, songStoryMode:Bool = false)
	{
		switch (eventName) {
			case "ChangeState" :
				FlxTransitionableState.skipNextTransIn = false;
				FlxTransitionableState.skipNextTransOut = false;
				if (eventValue == "storymode") {
					if (CustomMainMenuConfig.isScratchMenu[1] == true)
						{
							FlxG.save.data.currentState = CustomMainMenuConfig.mainMenuName[1];
							MusicBeatState.switchState(new CustomState());
						}
						else
						{
							MusicBeatState.switchState(new StoryMenuState());
						}
				}
				else if (eventValue == "freeplay") {
					if (CustomMainMenuConfig.isScratchMenu[2] == true)
						{
							FlxG.save.data.currentState = CustomMainMenuConfig.mainMenuName[2];
							MusicBeatState.switchState(new CustomState());
						}
						else
						{
							FlxTransitionableState.skipNextTransIn = true;
							FlxTransitionableState.skipNextTransOut = true;
							this.openSubState(new FreeplayState());
						}
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
					if (CustomMainMenuConfig.isScratchMenu[0] == true)
						{
							FlxG.save.data.currentState = CustomMainMenuConfig.mainMenuName[0];
							MusicBeatState.switchState(new CustomState());
						}
						else
						{
							MusicBeatState.switchState(new MainMenuState());
						}
				}
				else if (eventValue == "titlescreen") {
					MusicBeatState.switchState(new TitleState());
				}
				else {
					FlxG.save.data.currentState = eventValue;
					if (eventValue2 == 1) {
						eventValue2 = false;
					}
					FlxTransitionableState.skipNextTransIn = eventValue2;
					FlxTransitionableState.skipNextTransOut = eventValue2;

					if (songStoryMode)
					{
						openSubState(new StickerSubState(null, (sticker) -> new CustomState(sticker)));
					}
					else
					{
						MusicBeatState.switchState(new CustomState());
					}
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