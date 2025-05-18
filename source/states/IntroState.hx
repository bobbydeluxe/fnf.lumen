package states;

#if HSCRIPT_ALLOWED
import psychlua.HScript;
import crowplexus.iris.Iris;
#end

import misc.CustomMainMenuConfig;

class IntroState extends MusicBeatState {

    public static var customIntro = false; // can override this variable in hscript

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
                script.set('mainMenuConfig', CustomMainMenuConfig);
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

    override public function create():Void
    {
        super.create();

        CustomMainMenuConfig.reset();

        #if HSCRIPT_ALLOWED
		for (folder in Mods.directoriesWithFile(Paths.getSharedPath(), 'scripts/registry/'))
			for (file in FileSystem.readDirectory(folder))
			{

				#if HSCRIPT_ALLOWED
				if(file == 'intro.hx')
					initHScript(folder + file);
				#end
			}
		#end

        if (customIntro == false)
        {
            var text:FlxText = new FlxText(0, FlxG.height / 2 - 10, FlxG.width, "Press any key to continue");
            text.setFormat(null, 16, FlxColor.WHITE, "center");
            add(text);
        }

        callOnHScript("onCreatePost", []);
    }

    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);
        callOnHScript("onUpdate", [elapsed]);

        if (FlxG.keys.justPressed.ANY && customIntro == false)
        {
            MusicBeatState.switchState(new TitleState());  
        } // with customintro true, you can still make your own press any key mechanism
    }
}