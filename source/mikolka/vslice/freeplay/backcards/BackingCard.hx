package mikolka.vslice.freeplay.backcards;//

import mikolka.compatibility.VsliceOptions;
import mikolka.vslice.freeplay.FreeplayState;
import flixel.FlxCamera;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.math.FlxAngle;
import flixel.math.FlxPoint;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxSpriteUtil;
import flixel.util.FlxTimer;
import mikolka.funkin.players.PlayableCharacter;
import openfl.display.BlendMode;
import flixel.group.FlxSpriteGroup;
import mikolka.compatibility.FunkinPath as Paths;

import backend.Paths as PsychPaths;

import crowplexus.iris.Iris;
import psychlua.HScript;

import mikolka.vslice.freeplay.BGScrollingText;

/**
 * A class for the backing cards so they dont have to be part of freeplayState......
 */
class BackingCard extends FlxSpriteGroup
{
  public var backingTextYeah:FlxAtlasSprite;
  public var orangeBackShit:FunkinSprite;
  public var alsoOrangeLOL:FunkinSprite;
  public var pinkBack:FunkinSprite;
  public var confirmGlow:FlxSprite;
  public var confirmGlow2:FlxSprite;
  public var confirmTextGlow:FlxSprite;
  public var cardGlow:FlxSprite;

  var _exitMovers:Null<FreeplayState.ExitMoverData>;
  var _exitMoversCharSel:Null<FreeplayState.ExitMoverData>;

  public var instance:FreeplayState;

  public var characterVariable:PlayableCharacter; // Store the current playable character

  #if HSCRIPT_ALLOWED
	public var hscriptArray:Array<HScript> = [];
  public var hscriptScrollingTexts:Map<String, BGScrollingText> = new Map(); // Store HScript-created objects
	#end

  public function addBackingText(name:String, x:Float, y:Float, text:String, width:Float, isBold:Bool, size:Int):BGScrollingText {
    #if HSCRIPT_ALLOWED
    if (hscriptScrollingTexts.exists(name)) {
        trace("Warning: BGScrollingText '" + name + "' already exists!");
        var existingText:BGScrollingText = cast hscriptScrollingTexts.get(name);
        //existingText.changeText(text);
        return existingText;
    }

    var scrollingText = new BGScrollingText(x, y, text, width, isBold, size);
    add(scrollingText); // Add to FlxGroup
    hscriptScrollingTexts.set(name, scrollingText); // Store in the map
    return scrollingText;
    #end
  }


  public function removeBackingText(name:String):Void {
    #if HSCRIPT_ALLOWED
    if (hscriptScrollingTexts.exists(name)) {
        var textObject:BGScrollingText = hscriptScrollingTexts.get(name);
        if (textObject != null) {
            remove(textObject); // Remove from FlxGroup
            textObject.destroy(); // Properly clean up memory
            hscriptScrollingTexts.remove(name); // Remove from tracking map
            trace("Removed BGScrollingText: " + name);
        } else {
            trace("Warning: BGScrollingText '" + name + "' is null, but existed in the map!");
        }
    } else {
        trace("Warning: BGScrollingText '" + name + "' does not exist in the map!");
    }
    #end
  }

	public function callOnHScript(funcToCall:String, args:Array<Dynamic> = null) {
    #if HSCRIPT_ALLOWED
    for (script in hscriptArray) {
        if (script != null) {
            if (script.exists(funcToCall)) {
                script.call(funcToCall, args);
            }

            // Backing Card Functions
            script.set("addBackingText", addBackingText);
            script.set("removeBackingText", removeBackingText);
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

  public function new(currentCharacter:PlayableCharacter, ?_instance:FreeplayState)
  {
    var characterNameThingy:String = currentCharacter.getCodename(); 

    #if HSCRIPT_ALLOWED
   // var scriptPath = Mods.directoriesWithFile(Paths.getSharedPath(), 'data/haxescript/backingCards/' + characterNameThingy + 'Card.hx');
   var scriptPath = PsychPaths.getPath('data/haxescript/backingCards/' + characterNameThingy + 'Card.hx', TEXT, null, true);

		if (FileSystem.exists(scriptPath)) {
		    initHScript(scriptPath);
		} else {
		    trace('HScript file not found: ' + scriptPath);
		}
		#end

    super();

    if (_instance != null) instance = _instance;

    callOnHScript("onCreate", []);

    callOnHScript("onDJDataSent", [
      currentCharacter.getFreeplayDJText(1),
      currentCharacter.getFreeplayDJText(2),
      currentCharacter.getFreeplayDJText(3)
    ]);

    cardGlow = new FlxSprite(-30, -30).loadGraphic(Paths.image('freeplay/cardGlow'));
    confirmGlow = new FlxSprite(-30, 240).loadGraphic(Paths.image('freeplay/confirmGlow'));
    confirmTextGlow = new FlxSprite(-8, 115).loadGraphic(Paths.image('freeplay/glowingText'));
    pinkBack = FunkinSprite.create('freeplay/pinkBack');
    orangeBackShit = new FunkinSprite(84, 440).makeSolidColor(Std.int(pinkBack.width), 75, 0xFFFEDA00);
    alsoOrangeLOL = new FunkinSprite(0, orangeBackShit.y).makeSolidColor(100, Std.int(orangeBackShit.height), 0xFFFFD400);
    confirmGlow2 = new FlxSprite(confirmGlow.x, confirmGlow.y).loadGraphic(Paths.image('freeplay/confirmGlow2'));
    backingTextYeah = new FlxAtlasSprite(640, 370, Paths.animateAtlas("freeplay/backing-text-yeah"),
      {
        FrameRate: 24.0,
        Reversed: false,
        // ?OnComplete:Void -> Void,
        ShowPivot: false,
        Antialiasing: true,
        ScrollFactor: new FlxPoint(1, 1),
      });

    pinkBack.color = 0xFFFFD4E9; // sets it to pink!
    pinkBack.x -= pinkBack.width;

    callOnHScript("onCreatePost", []);
  }

  /**
   * Apply exit movers for the pieces of the backing card.
   * @param exitMovers The exit movers to apply.
   */
  public function applyExitMovers(?exitMovers:FreeplayState.ExitMoverData, ?exitMoversCharSel:FreeplayState.ExitMoverData):Void
  {

    if (exitMovers == null)
    {
      exitMovers = _exitMovers;
    }
    else
    {
      _exitMovers = exitMovers;
    }

    if (exitMovers == null) return;

    if (exitMoversCharSel == null)
    {
      exitMoversCharSel = _exitMoversCharSel;
    }
    else
    {
      _exitMoversCharSel = exitMoversCharSel;
    }

    if (exitMoversCharSel == null) return;

    exitMovers.set([pinkBack, orangeBackShit, alsoOrangeLOL],
      {
        x: -pinkBack.width,
        y: pinkBack.y,
        speed: 0.4,
        wait: 0
      });

    exitMoversCharSel.set([pinkBack],
      {
        y: -100,
        speed: 0.8,
        wait: 0.1
      });

    exitMoversCharSel.set([orangeBackShit, alsoOrangeLOL],
      {
        y: -40,
        speed: 0.8,
        wait: 0.1
      });
  }

  /**
   * Helper function to snap the back of the card to its final position.
   * Used when returning from character select, as we dont want to play the full animation of everything sliding in.
   */
  public function skipIntroTween():Void
  {
    FlxTween.cancelTweensOf(pinkBack);
    pinkBack.x = 0;
  }

  /**
   * Called in create. Adds sprites and tweens.//
   */
  public function init():Void
  {

    callOnHScript("onInitSetup", []);

    FlxTween.tween(pinkBack, {x: 0}, 0.6, {ease: FlxEase.quartOut});
    add(pinkBack);
    callOnHScript("onLoad",["pinkBack",pinkBack]);
    add(orangeBackShit);
    callOnHScript("onLoad",["orangeBackShit",orangeBackShit]);
    add(alsoOrangeLOL);
    callOnHScript("onLoad",["alsoOrangeLOL",alsoOrangeLOL]);

    //FlxSpriteUtil.alphaMaskFlxSprite(orangeBackShit, pinkBack, orangeBackShit);
    orangeBackShit.visible = false;
    alsoOrangeLOL.visible = false;

    confirmTextGlow.blend = BlendMode.ADD;
    confirmTextGlow.visible = false;

    confirmGlow.blend = BlendMode.ADD;//

    confirmGlow.visible = false;
    confirmGlow2.visible = false;

    add(confirmGlow2);
    callOnHScript("onLoad",["confirmGlow2",confirmGlow2]);
    add(confirmGlow);
    callOnHScript("onLoad",["confirmGlow",confirmGlow]);
    add(confirmTextGlow);
    callOnHScript("onLoad",["confirmTextGlow",confirmTextGlow]);
    add(backingTextYeah);
    callOnHScript("onLoad",["backingTextYeah",backingTextYeah]);
    cardGlow.blend = BlendMode.ADD;
    cardGlow.visible = false;

    add(cardGlow);
  }

  /**
   * Called after the dj finishes their start animation.
   */
  public function introDone():Void
  {
    if(!VsliceOptions.ALLOW_COLORING) pinkBack.color = 0xFFFFD863;
    callOnHScript("onIntroDone",[]);
    orangeBackShit.visible = true;
    alsoOrangeLOL.visible = true;
    cardGlow.visible = true;
    FlxTween.tween(cardGlow, {alpha: 0, "scale.x": 1.2, "scale.y": 1.2}, 0.45, {ease: FlxEase.sineOut});
  }

  /**
   * Called when selecting a song.
   */
  public function confirm():Void
  {
    FlxTween.color(pinkBack, 0.33, 0xFFFFD0D5, 0xFF171831, {ease: FlxEase.quadOut});
    callOnHScript("onDisappear", []);
    orangeBackShit.visible = false;
    alsoOrangeLOL.visible = false;

    confirmGlow.visible = true;
    confirmGlow2.visible = true;

    backingTextYeah.anim.play("");
    confirmGlow2.alpha = 0;
    confirmGlow.alpha = 0;

    FlxTween.color(instance.bgDad, 0.5, 0xFFA8A8A8, 0xFF646464,
      {
        onUpdate: function(_) {
          instance.angleMaskShader.extraColor = instance.bgDad.color;
        }
      });
    FlxTween.tween(confirmGlow2, {alpha: 0.5}, 0.33,
      {
        ease: FlxEase.quadOut,
        onComplete: function(_) {
          confirmGlow2.alpha = 0.6;
          confirmGlow.alpha = 1;
          confirmTextGlow.visible = true;
          confirmTextGlow.alpha = 1;
          FlxTween.tween(confirmTextGlow, {alpha: 0.4}, 0.5);
          FlxTween.tween(confirmGlow, {alpha: 0}, 0.5);
          FlxTween.color(instance.bgDad, 2, 0xFFCDCDCD, 0xFF555555,
            {
              ease: FlxEase.expoOut,
              onUpdate: function(_) {
                instance.angleMaskShader.extraColor = instance.bgDad.color;
              }
            });
        }
      });
  }

  /**
   * Called when entering character select, does nothing by default.
   */
  public function enterCharSel():Void {}

  /**
   * Called on each beat in freeplay state.
   */
  public function beatHit(curBeat:Int):Void {
    callOnHScript("onBeatHit", [curBeat]);
  }

  /**
   * Called when exiting the freeplay menu.
   */
  public function disappear():Void
  {
    FlxTween.color(pinkBack, 0.25, pinkBack.color, 0xFFFFD0D5, {ease: FlxEase.quadOut});

    callOnHScript("onDisappear", []);

    cardGlow.visible = true;
    cardGlow.alpha = 1;
    cardGlow.scale.set(1, 1);
    FlxTween.tween(cardGlow, {alpha: 0, "scale.x": 1.2, "scale.y": 1.2}, 0.25, {ease: FlxEase.sineOut});

    orangeBackShit.visible = false;
    alsoOrangeLOL.visible = false;
  }
}
