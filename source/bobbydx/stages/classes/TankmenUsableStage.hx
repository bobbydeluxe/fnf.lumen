package bobbydx.stages.classes;

class TankmenUsableStage extends BaseStage
{
	var tankmanRun:FlxTypedGroup<TankmenBG>;

	override function create()
	{
		tankmanRun = new FlxTypedGroup<TankmenBG>();
		add(tankmanRun);

		super.create();
	}
	override function createPost()
	{
		super.createPost();
		add(foregroundSprites);

		if(!VsliceOptions.LOW_QUALITY)
		{
			for (daGf in gfGroup)
			{
				var gf:Character = cast daGf;
				if (gf.curCharacter.indexOf("shoot") != -1 && StringTools.endsWith(gf.curCharacter, "-week7"))
				{
					var firstTank:TankmenBG = new TankmenBG(20, 500, true);
					firstTank.resetShit(20, 1500, true);
					firstTank.strumTime = 10;
					firstTank.visible = false;
					tankmanRun.add(firstTank);

					for (i in 0...TankmenBG.animationNotes.length)
					{
						if(FlxG.random.bool(16)) {
							var tankBih = tankmanRun.recycle(TankmenBG);
							tankBih.strumTime = TankmenBG.animationNotes[i][0];
							tankBih.resetShit(500, 200 + FlxG.random.int(50, 100), TankmenBG.animationNotes[i][1] < 2);
							tankmanRun.add(tankBih);
						}
					}
					break;
				}
			}
		}
	}

	override function countdownTick(count:Countdown, num:Int) if(num % 2 == 0) everyoneDance();
	override function beatHit() {
		everyoneDance();
		super.beatHit();
	}
	function everyoneDance()
	{
		if(!VsliceOptions.LOW_QUALITY) tankWatchtower.dance();
		foregroundSprites.forEach(function(spr:BGSprite)
		{
			spr.dance();
		});
	}
}