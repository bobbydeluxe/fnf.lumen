package states;

// code by polo and anas [from the psych engine discord server]
// modified by bobbyDX [me] for linux support using hxCodec

#if linux
import hxCodec.flixel.FlxVideoSprite;
#else
import hxvlc.flixel.FlxVideoSprite;
#end

class IntroVideoState extends MusicBeatState
{
    public var videoCutscene:FlxVideoSprite;
    override public function create():Void
    {
            startVideo('intro'); // custom haxeflixel video splash screen

        super.create();
    }

       public function startVideo(name:String)
    {
        videoCutscene = new FlxVideoSprite(0, 0);
        add(videoCutscene);
        videoCutscene.load(Paths.video(name));
        videoCutscene.play();
        videoCutscene.alpha = 1;
        videoCutscene.visible = true;
        videoCutscene.bitmap.onEndReached.add(function()
        {
            new FlxTimer().start(0.1, function(tmr:FlxTimer)
            {
                MusicBeatState.switchState(new TitleState());
            });
        });
    }
    
    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);
        if (FlxG.keys.justPressed.ANY)
        {
            videoCutscene.stop();  
            MusicBeatState.switchState(new TitleState());  
        }
    }
}