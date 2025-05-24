package states;

import mikolka.compatibility.ModsHelper;
import mikolka.vslice.freeplay.FreeplayState;
import flixel.FlxObject;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import lime.app.Application;
import states.editors.MasterEditorMenu;
import options.OptionsState;
import backend.Song;
import substates.StickerSubState;
#if HSCRIPT_ALLOWED
import crowplexus.iris.Iris;
import psychlua.HScript;
#end

class MainMenuState extends MusicBeatState
{
	public static var lumenEngineVersion:String = '1.0'; // Similar to DuskieWhy's NightmareVision engine, Lumen Engine does not follow a strict versioning system, so 1.0 acts as a placeholder.
	public static var isLumen:Bool = true; // This is used for Lua functions to check if the engine is Lumen Engine or not.
	public static var psychEngineVersion:String = '1.0'; // This is also used for Discord RPC
	public static var pSliceVersion:String = '2.2.2'; 
	public static var funkinVersion:String = '0.2.8';
	public static var curSelected:Int = 0;

	#if HSCRIPT_ALLOWED
	public var hscriptArray:Array<HScript> = [];
	#end

	var menuItemsBack:FlxTypedGroup<FlxSprite>;
	var menuItems:FlxTypedGroup<FlxSprite>;

	public static var menuItemCenter:Bool = true;
	public static var menuItemOffset:Float = 0;

	var optionShit:Array<String> = [
		'story_mode',
		'freeplay',
		#if MODS_ALLOWED 'mods', #end
		#if ACHIEVEMENTS_ALLOWED 'awards', #end
		'credits',
		'options'
	];

	var magenta:FlxSprite;
	var camFollow:FlxObject;

	var cancelLoad:Bool = false;
	
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


	override function create()
	{
		Paths.clearUnusedMemory();

		if (stickerSubState != null)
		{
		  //this.persistentUpdate = true;
		  //this.persistentDraw = true
		  openSubState(stickerSubState);
		  ModsHelper.clearStoredWithoutStickers();
		  stickerSubState.degenStickers();
		  FlxG.sound.playMusic(Paths.music('freakyMenu'));
		}
		
		#if MODS_ALLOWED
		Mods.pushGlobalMods();
		#end
		Mods.loadTopMod();

		#if DISCORD_ALLOWED
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		#if HSCRIPT_ALLOWED
		for (folder in Mods.directoriesWithFile(Paths.getSharedPath(), 'scripts/states/mainmenu/'))
			for (file in FileSystem.readDirectory(folder))
			{

				#if HSCRIPT_ALLOWED
				if(file.toLowerCase().endsWith('.hx'))
					initHScript(folder + file);
				#end
			}
		#end


		persistentUpdate = persistentDraw = true;

		var yScroll:Float = Math.max(0.25 - (0.05 * (optionShit.length - 4)), 0.1);
		var bg:FlxSprite = new FlxSprite(-80).loadGraphic(Paths.image('menuBG'));
		bg.antialiasing = ClientPrefs.data.antialiasing;
		bg.scrollFactor.set(0, yScroll);
		bg.setGraphicSize(Std.int(bg.width * 1.175));
		bg.updateHitbox();
		bg.screenCenter();
		add(bg);
		callOnHScript("onLoad",["bg",bg]);

		camFollow = new FlxObject(0, 0, 1, 1);
		add(camFollow);
		callOnHScript("onLoad",["camFollow",camFollow]);

		magenta = new FlxSprite(-80).loadGraphic(Paths.image('menuDesat'));
		magenta.antialiasing = ClientPrefs.data.antialiasing;
		magenta.scrollFactor.set(0, yScroll);
		magenta.setGraphicSize(Std.int(magenta.width * 1.175));
		magenta.updateHitbox();
		magenta.screenCenter();
		magenta.visible = false;
		magenta.color = 0xFFfd719b;
		add(magenta);
		callOnHScript("onLoad",["magenta",magenta]);

		menuItemsBack = new FlxTypedGroup<FlxSprite>();
		add(menuItemsBack);
		callOnHScript("onLoad",["menuItemsBack",menuItemsBack]);


		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);
		callOnHScript("onLoad",["menuItems",menuItems]);

		for (i in 0...optionShit.length)
		{
			var offset:Float = 108 - (Math.max(optionShit.length, 4) - 4) * 80;
			var menuItem:FlxSprite = new FlxSprite(menuItemOffset, (i * 140) + offset);
			menuItem.antialiasing = ClientPrefs.data.antialiasing;
			menuItem.frames = Paths.getSparrowAtlas('mainmenu/menu_' + optionShit[i]);
			menuItem.animation.addByPrefix('idle', optionShit[i] + " basic", 24);
			menuItem.animation.addByPrefix('selected', optionShit[i] + " white", 24);
			menuItem.animation.play('idle');
			menuItems.add(menuItem);
			callOnHScript("onCreateMenuItems",[i,menuItem]);
			var scr:Float = (optionShit.length - 4) * 0.135;
			if (optionShit.length < 6)
				scr = 0;
			menuItem.scrollFactor.set(0, scr);
			menuItem.updateHitbox();
			if (menuItemCenter == true)
				menuItem.screenCenter(X);
		}

		var lumenVer:FlxText = new FlxText(12, FlxG.height - 64, 0, "Lumen Engine (P-Slice " + pSliceVersion + ")", 12);
		lumenVer.scrollFactor.set();
		lumenVer.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(lumenVer);
		callOnHScript("onLoad",["lumenVerText",lumenVer]);
		var psychVer:FlxText = new FlxText(12, FlxG.height - 44, 0, "Psych Engine v" + psychEngineVersion, 12);
		psychVer.scrollFactor.set();
		psychVer.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(psychVer);
		callOnHScript("onLoad",["psychVerText",psychVer]);
		var fnfVer:FlxText = new FlxText(12, FlxG.height - 24, 0, "Friday Night Funkin' v" + funkinVersion, 12);
		fnfVer.scrollFactor.set();
		fnfVer.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(fnfVer);
		callOnHScript("onLoad",["fnfVerText",fnfVer]);
	
		changeItem();

		#if ACHIEVEMENTS_ALLOWED
		// Unlocks "Freaky on a Friday Night" achievement if it's a Friday and between 18:00 PM and 23:59 PM
		var leDate = Date.now();
		if (leDate.getDay() == 5 && leDate.getHours() >= 18)
			Achievements.unlock('friday_night_play');

		#if MODS_ALLOWED
		Achievements.reloadList();
		#end
		#end

		#if TOUCH_CONTROLS_ALLOWED
		addTouchPad('LEFT_FULL', 'A_B_E');
		#end

		super.create();

		FlxG.camera.follow(camFollow, null, 0.06);

		callOnHScript("onCreatePost",[]);
	}

	var selectedSomethin:Bool = false;

	override function update(elapsed:Float)
	{

		callOnHScript("onUpdate",[elapsed]);

		if (FlxG.sound.music.volume < 0.8)
		{
			FlxG.sound.music.volume += 0.5 * elapsed;
			//if (FreeplayState.vocals != null)
				//FreeplayState.vocals.volume += 0.5 * elapsed;
		}

		if (!selectedSomethin)
		{
			if (controls.UI_UP_P)
				changeItem(-1);

			if (controls.UI_DOWN_P)
				changeItem(1);

			if (controls.BACK)
			{
				selectedSomethin = true;
				FlxG.sound.play(Paths.sound('cancelMenu'));
				MusicBeatState.switchState(new TitleState());
			}

			if (controls.ACCEPT)
			{
				FlxG.sound.play(Paths.sound('confirmMenu'));
				FlxTransitionableState.skipNextTransIn = false;
				FlxTransitionableState.skipNextTransOut = false;
				if (optionShit[curSelected] == 'donate')
				{
					CoolUtil.browserLoad('https://www.makeship.com/shop/creator/friday-night-funkin');
				}
				else
				{
					selectedSomethin = true;

					if (ClientPrefs.data.flashing)
						FlxFlicker.flicker(magenta, 1.1, 0.15, false);

					FlxFlicker.flicker(menuItems.members[curSelected], 1, 0.06, false, false, function(flick:FlxFlicker)
					{
						callOnHScript("onStart", [optionShit[curSelected]]);
						if (cancelLoad == false) {
							switch (optionShit[curSelected])
							{
								case 'story_mode':
									MusicBeatState.switchState(new StoryMenuState());
								case 'freeplay':
									persistentDraw = true;
                    				persistentUpdate = false;
                    				// Freeplay has its own custom transition
                    				FlxTransitionableState.skipNextTransIn = true;
                    				FlxTransitionableState.skipNextTransOut = true;

                    				openSubState(new FreeplayState());
                    				subStateOpened.addOnce(state -> {
                    				    for (i in 0...menuItems.members.length) {
                    				        menuItems.members[i].revive();
                    				        menuItems.members[i].alpha = 1;
                    				        menuItems.members[i].visible = true;
                    				        selectedSomethin = false;
                    				    }
                    				    changeItem(0);
                    				});
	
								#if MODS_ALLOWED
								case 'mods':
									MusicBeatState.switchState(new ModsMenuState());
								#end
	
								#if ACHIEVEMENTS_ALLOWED
								case 'awards':
									MusicBeatState.switchState(new AchievementsMenuState());
								#end
	
								case 'credits':
									MusicBeatState.switchState(new CreditsState());
								case 'options':
									MusicBeatState.switchState(new OptionsState());
									OptionsState.onPlayState = false;
									if (PlayState.SONG != null)
									{
										PlayState.SONG.arrowSkin = null;
										PlayState.SONG.splashSkin = null;
										PlayState.stageUI = 'normal';
									}
							}
						}
					});

					for (i in 0...menuItems.members.length)
					{
						if (i == curSelected)
							continue;
						FlxTween.tween(menuItems.members[i], {alpha: 0}, 0.4, {
							ease: FlxEase.quadOut,
							onComplete: function(twn:FlxTween)
							{
								menuItems.members[i].kill();
							}
						});
					}
				}
			}
			if (#if TOUCH_CONTROLS_ALLOWED touchPad.buttonE.justPressed || #end controls.justPressed('debug_1'))
			{
				selectedSomethin = true;
				FlxTransitionableState.skipNextTransIn = false;
				FlxTransitionableState.skipNextTransOut = false;
				MusicBeatState.switchState(new MasterEditorMenu());
			}
		}

		super.update(elapsed);
		callOnHScript("onUpdatePost",[elapsed]);
	}

	function triggerEvent(eventName:String,eventValue:Dynamic = 1,eventValue2:Dynamic = 1, songStoryMode:Bool = false) {
		switch (eventName) {
			case "ChangeState" :
				if (eventValue == "storymode") {
					MusicBeatState.switchState(new StoryMenuState());
				}
				else if (eventValue == "freeplay") {
					persistentDraw = true;
					persistentUpdate = false;
					// Freeplay has its own custom transition
					FlxTransitionableState.skipNextTransIn = true;
					FlxTransitionableState.skipNextTransOut = true;

					openSubState(new FreeplayState());
					subStateOpened.addOnce(state -> {
						for (i in 0...menuItems.members.length) {
							menuItems.members[i].revive();
							menuItems.members[i].alpha = 1;
							menuItems.members[i].visible = true;
							selectedSomethin = false;
						}
						changeItem(0);
					});
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
				else if (eventValue == "titlescreen") {
					MusicBeatState.switchState(new TitleState());
				}
				else {
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

	function changeItem(huh:Int = 0)
	{
		FlxG.sound.play(Paths.sound('scrollMenu'));
		menuItems.members[curSelected].animation.play('idle');
		menuItems.members[curSelected].updateHitbox();
		if (menuItemCenter == true)
			menuItems.members[curSelected].screenCenter(X);

		curSelected += huh;

		if (curSelected >= menuItems.length)
			curSelected = 0;
		if (curSelected < 0)
			curSelected = menuItems.length - 1;

		menuItems.members[curSelected].animation.play('selected');
		menuItems.members[curSelected].centerOffsets();
		if (menuItemCenter == true)
			menuItems.members[curSelected].screenCenter(X);

		camFollow.setPosition(menuItems.members[curSelected].getGraphicMidpoint().x,
			menuItems.members[curSelected].getGraphicMidpoint().y - (menuItems.length > 4 ? menuItems.length * 8 : 0));
	}
}
