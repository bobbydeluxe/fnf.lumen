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
import backend.StateScriptBank;

import substates.CustomSubstate;

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
			newScript.set("Bank", StateScriptBank);
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

    function triggerSwitch(type:String, data:Array<Dynamic> = null, trans:Array<Bool> = null):Void {
	switch (type) {
		case "changeState":
			var target:String = data[0];
			var skipIn = trans != null && trans.length > 1 ? trans[0] : false;
			var skipOut = trans != null && trans.length > 2 ? trans[1] : false;

			FlxTransitionableState.skipNextTransIn = skipIn;
			FlxTransitionableState.skipNextTransOut = skipOut;

			switch (target) {
				case "StoryMenuState":
					if (CustomMainMenuConfig.isScratchMenu[1]) {
						currentState = CustomMainMenuConfig.mainMenuName[1];
						MusicBeatState.switchState(new CustomState());
					} else {
						MusicBeatState.switchState(new StoryMenuState());
					}

				case "FreeplayState":
					if (CustomMainMenuConfig.isScratchMenu[2]) {
						currentState = CustomMainMenuConfig.mainMenuName[2];
						MusicBeatState.switchState(new CustomState());
					} else {
						openSubState(new FreeplayState());
					}

				case "CreditsState": MusicBeatState.switchState(new CreditsState());
				case "OptionsState":
					MusicBeatState.switchState(new OptionsState());
					OptionsState.onPlayState = false;
					if (PlayState.SONG != null) {
						PlayState.SONG.arrowSkin = null;
						PlayState.SONG.splashSkin = null;
						PlayState.stageUI = 'normal';
					}

				case "AwardsState": MusicBeatState.switchState(new AchievementsMenuState());
				case "ModsState": MusicBeatState.switchState(new ModsMenuState());
				case "MainMenuState":
					if (CustomMainMenuConfig.isScratchMenu[0]) {
						FlxG.save.data.currentState = CustomMainMenuConfig.mainMenuName[0];
						MusicBeatState.switchState(new CustomState());
					} else {
						MusicBeatState.switchState(new MainMenuState());
					}

				case "TitleState": MusicBeatState.switchState(new TitleState());

				default:
					FlxG.save.data.currentState = target;
					
					if (trans[3]) {
							openSubState(new StickerSubState(null, (sticker) -> new CustomState(sticker)));
					} else {
						MusicBeatState.switchState(new CustomState());
					}
			}
        case "loadSong":
            var songLowercase:String = Paths.formatToSongPath(data[0]);
			var poop:String = Highscore.formatSong(songLowercase, data[1]);
	
			try
			{
				Song.loadFromJson(poop, songLowercase);
				PlayState.isStoryMode = data[2];
				PlayState.storyDifficulty = data[1];
			}

			if (FlxG.save.data.isTransition == false) {
				MusicBeatState.switchState(new PlayState());
			} else {
				LoadingState.loadAndSwitchState(new PlayState());
			}
		case "openSubState":
			FlxG.save.data.currentSubstate = data[0];
			openSubState(new CustomSubstate());
		default:
			trace('Unknown triggerSwitch type: $type');
		}
	}
}