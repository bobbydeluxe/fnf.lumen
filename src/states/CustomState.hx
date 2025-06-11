package states;

import psychlua.HScript;
import crowplexus.iris.Iris;

import backend.Song;
import backend.Highscore;
import options.OptionsState;
import mikolka.vslice.freeplay.FreeplayState;
import states.PlayState;
import substates.StickerSubState;
import mikolka.compatibility.ModsHelper;

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
        var scriptFolder = null;
        for (folder in Mods.directoriesWithFile(Paths.getSharedPath(), 'scripts/states/custom/'))
            scriptFolder = folder; // Use the first found folder

        if (scriptFolder != null) {
            var mainScriptPath = scriptFolder + currentState + ".hx";
            if (FileSystem.exists(mainScriptPath)) {
                initHScript(mainScriptPath);
            } else {
                trace('Main.hx not found in ' + scriptFolder);
            }
        }
        #end
    }

    override function update(elapsed:Float) {
        callOnHScript("onUpdate", [elapsed]);
        super.update(elapsed);
        callOnHScript("onUpdatePost", [elapsed]);
    }

    function openSub(item:Dynamic) {
        openSubState(item);
    }
}