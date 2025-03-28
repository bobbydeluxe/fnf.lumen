package states;

import hxvlc.flixel.FlxVideoSprite;

class IntroVideoState extends MusicBeatState
{
    public var videoCutscene:FlxVideoSprite;
    override public function create():Void
    {
            startVideo('introFlixel'); // change this boi

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