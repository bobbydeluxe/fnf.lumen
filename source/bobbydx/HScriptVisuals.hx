package bobbydx;

import flixel.addons.display.FlxBackdrop;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import openfl.display.BlendMode;
import mikolka.compatibility.FunkinPath as Paths;
import mikolka.vslice.freeplay.BGScrollingText;
import flixel.util.FlxGradient;

class HScriptVisuals {
  public var hscriptScrollingTexts:Map<String, BGScrollingText>;
  public var hscriptObjects:Map<String, Dynamic>;
  public var group:FlxSpriteGroup;

  public var callback:(String, Array<Dynamic>) -> Void;

  public function new(_group:FlxSpriteGroup, _hscriptObjects:Map<String, Dynamic>, ?_callback:(String, Array<Dynamic>) -> Void) {
    group = _group;
    hscriptObjects = _hscriptObjects;
    hscriptScrollingTexts = new Map();
    callback = _callback;
  }

  // ──────────────────────────────────────────────
  // Text Functions
  // ──────────────────────────────────────────────

  public function addBackingText(name:String, x:Float, y:Float, text:String, width:Float, isBold:Bool, size:Int):BGScrollingText {
    #if HSCRIPT_ALLOWED
    if (hscriptScrollingTexts.exists(name)) {
      trace("Warning: BGScrollingText '" + name + "' already exists!");
      return hscriptScrollingTexts.get(name);
    }

    var scrollingText = new BGScrollingText(x, y, text, width, isBold, size);
    group.add(scrollingText);
    hscriptScrollingTexts.set(name, scrollingText);
    hscriptObjects.set(name, scrollingText);
    if (callback != null)
      callback("onTextAdded", [name, scrollingText]);
    return scrollingText;
    #end
  }

  public function removeBackingText(name:String):Void {
    #if HSCRIPT_ALLOWED
    if (hscriptScrollingTexts.exists(name)) {
      var obj = hscriptScrollingTexts.get(name);
      group.remove(obj);
      obj.destroy();
      hscriptScrollingTexts.remove(name);
      hscriptObjects.remove(name);
      if (callback != null)
      callback("onTextRemoved", [name]);
    }
    #end
  }

  // ──────────────────────────────────────────────
  // Static / Animated / Atlas Sprite (non-repeating)
  // ──────────────────────────────────────────────

  public function addVisualSprite(name:String, path:String, type:String = "static", x:Float = 0, y:Float = 0, ?blend:BlendMode = null, alpha:Float = 1.0, anims:Array<{prefix:String, fps:Int}> = null, startAnim:String = "") {
    #if HSCRIPT_ALLOWED
    if (hscriptObjects.exists(name)) {
      trace("Warning: Sprite '" + name + "' already exists!");
      return;
    }

    var sprite:FlxSprite = null;

    switch (type) {
      case "static":
        sprite = new FlxSprite(x, y).loadGraphic(Paths.image(path));

      case "animated":
        sprite = new FlxSprite(x, y);
        sprite.frames = Paths.getSparrowAtlas(path);
        if (anims != null) {
          for (anim in anims)
            sprite.animation.addByPrefix(anim.prefix, anim.prefix, anim.fps, true);
        }
        if (startAnim != "") sprite.animation.play(startAnim);

      case "atlas":
        var atlas = new FlxAtlasSprite(x, y, Paths.animateAtlas(path));
        if (anims != null) {
          for (anim in anims)
            atlas.animation.addByPrefix(anim.prefix, anim.prefix, anim.fps, true);
        }
        if (startAnim != "") atlas.animation.play(startAnim);
        sprite = cast atlas;

      default:
        trace("Unknown sprite type: " + type);
        return;
    }

    sprite.alpha = alpha;
    if (blend != null) sprite.blend = blend;

    group.add(sprite);
    hscriptObjects.set(name, sprite);
    if (callback != null)
      callback("onSpriteAdded", [name, sprite]);
    #end
  }

  public function playSpriteAnim(name:String, anim:String, force:Bool = false) {
    #if HSCRIPT_ALLOWED
    if (!hscriptObjects.exists(name)) return;
    var spr = hscriptObjects.get(name);
    if (spr is FlxSprite && cast(spr, FlxSprite).animation.exists(anim)) {
      cast(spr, FlxSprite).animation.play(anim, force);
      if (callback != null)
      callback("onSpriteAnimPlayed", [name, anim]);
    }
    #end
  }

  public function setSpriteColor(name:String, color:Int) {
    #if HSCRIPT_ALLOWED
    if (hscriptObjects.exists(name)) {
      var spr:FlxSprite = cast hscriptObjects.get(name);
      spr.color = color;
      if (callback != null)
      callback("onSpriteColorChanged", [name, color]);
    }
    #end
  }

  public function setSpriteAlpha(name:String, alpha:Float) {
    #if HSCRIPT_ALLOWED
    if (hscriptObjects.exists(name)) {
      var obj = hscriptObjects.get(name);
      if (!(obj is FlxSprite)) return;
      var spr:FlxSprite = cast obj;
      spr.alpha = alpha;
      if (callback != null)
        callback("onSpriteAlphaChanged", [name, alpha]);
    }
    #end
  }
  

  public function setSpriteVisible(name:String, visible:Bool) {
    #if HSCRIPT_ALLOWED
    if (hscriptObjects.exists(name)) {
      var spr:FlxSprite = cast hscriptObjects.get(name);
      spr.visible = visible;
      if (callback != null)
      callback("onSpriteVisChanged", [name, visible]);
    }
    #end
  }

  public function createGradientSprite(width:Int, height:Int, colors:Array<UInt>, angle:Int = 90):FlxSprite {
    var spr = new FlxSprite();
    var gradient = FlxGradient.createGradientFlxSprite(width, height, colors, angle);
    spr.makeGraphic(width, height, 0x00000000); // transparent base
    spr.pixels = gradient.pixels; // copy the generated gradient pixels
    spr.updateHitbox();
    return spr;
  }

  // ──────────────────────────────────────────────
  // Repeating Background Layers (FlxBackdrop)
  // ──────────────────────────────────────────────

  public function addBGImageLayer(name:String, path:String, speed:Float = 100, x:Float = 0, y:Float = 0, flipX:Bool = false, alpha:Float = 1.0, anims:Array<{prefix:String, fps:Int}> = null, startAnim:String = "") {
    #if HSCRIPT_ALLOWED
    if (hscriptObjects.exists(name)) {
      trace("Warning: BG Layer '" + name + "' already exists!");
      return;
    }

    var backdrop = new FlxBackdrop(Paths.image(path), X, 20);
    backdrop.setPosition(x, y);
    backdrop.velocity.x = speed;
    backdrop.flipX = flipX;
    backdrop.alpha = alpha;

    if (anims != null && anims.length > 0) {
      backdrop.frames = Paths.getSparrowAtlas(path);
      for (anim in anims) {
        backdrop.animation.addByPrefix(anim.prefix, anim.prefix, anim.fps, true);
      }
      if (startAnim != "") backdrop.animation.play(startAnim);
    }

    group.add(backdrop);
    hscriptObjects.set(name, backdrop);
    if (callback != null)
      callback("onBGImageLayerAdded", [name, backdrop]);
    #end
  }

  public function playBGLayerAnimation(name:String, anim:String) {
    #if HSCRIPT_ALLOWED
    if (!hscriptObjects.exists(name)) return;
    var obj = hscriptObjects.get(name);
    if (!(obj is FlxBackdrop)) return;
    var layer:FlxBackdrop = cast obj;
    if (layer.animation.exists(anim)) {
      layer.animation.play(anim);
      if (callback != null)
      callback("onBGLayerAnimPlayed", [name, anim]);
    }
    #end
  }

  public function setBGLayerSpeed(name:String, speed:Float) {
    #if HSCRIPT_ALLOWED
    if (!hscriptObjects.exists(name)) return;
    
    var obj = hscriptObjects.get(name);
    if (!(obj is FlxBackdrop)) return;
    var layer:FlxBackdrop = cast obj;


    layer.velocity.x = speed;
    if (callback != null)
      callback("onBGLayerSpeedChanged", [name, speed]);
    #end
  }

  public function setBGLayerAlpha(name:String, alpha:Float) {
    #if HSCRIPT_ALLOWED
    if (!hscriptObjects.exists(name)) return;
    
    var obj = hscriptObjects.get(name);
    if (!(obj is FlxBackdrop)) return;
    var layer:FlxBackdrop = cast obj;


    layer.alpha = alpha;
    if (callback != null)
      callback("onBGLayerAlphaChanged", [name, alpha]);
    #end
  }

  public function setBGLayerBlending(name:String, blend:BlendMode) {
    #if HSCRIPT_ALLOWED
    if (!hscriptObjects.exists(name)) return;
    var layer = cast(hscriptObjects.get(name), FlxSprite);
    layer.blend = blend;
    if (callback != null)
      callback("onBGLayerBlendingChanged", [name, blend]);
    #end
  }

  public function flipBGLayer(name:String, flipX:Bool) {
    #if HSCRIPT_ALLOWED
    if (!hscriptObjects.exists(name)) return;
    
    var obj = hscriptObjects.get(name);
    if (!(obj is FlxBackdrop)) return;
    var layer:FlxBackdrop = cast obj;


    layer.flipX = flipX;
    if (callback != null)
      callback("onBGLayerFlipped", [name, flipX]);
    #end
  }

  // ──────────────────────────────────────────────
  // General Functions
  // ──────────────────────────────────────────────

  public function removeObject(name:String) {
    #if HSCRIPT_ALLOWED
    if (!hscriptObjects.exists(name)) return;
    var obj = hscriptObjects.get(name);
    group.remove(obj);
    obj.destroy();
    hscriptObjects.remove(name);
    if (callback != null)
      callback("onObjectRemoved", [name]);
    #end
  }

  public function get(name:String):Dynamic {
    return hscriptObjects.get(name);
  }
  
}
