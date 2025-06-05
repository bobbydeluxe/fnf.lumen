package substates;

import psychlua.HScript;
import crowplexus.iris.Iris;

import substates.StickerSubState;
import mikolka.compatibility.ModsHelper;
import backend.StateScriptBank;

class CustomSubstate extends MusicBeatSubstate
{
    var currentSubstate = FlxG.save.data.currentSubstate;

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
				script.set('sub', this);
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
			newScript.set('Bank', StateScriptBank);
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

        #if HSCRIPT_ALLOWED
		for (folder in Mods.directoriesWithFile(Paths.getSharedPath(), 'scripts/substates/custom/' + currentSubstate + '/'))
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

	override function destroy() {
		callOnHScript("onDestroy");
		#if HSCRIPT_ALLOWED
		for (script in hscriptArray) {
			if (script != null) {
				script.destroy();
			}
		}
		hscriptArray = [];
		#end
		super.destroy();
	}

	override function close() {
		callOnHScript("onClose");
		super.close();
		// we not destroyin the hscript here, because 1 - idk how; 2 - we can make custom exit transitions
		// and we want to keep the hscript alive for that
	}
}