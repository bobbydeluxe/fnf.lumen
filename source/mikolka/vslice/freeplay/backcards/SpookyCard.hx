package mikolka.vslice.freeplay.backcards;

import flixel.FlxSprite;
import flixel.addons.display.FlxBackdrop;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxMath;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxSpriteUtil;
import mikolka.compatibility.FreeplayHelpers;
import mikolka.compatibility.FunkinPath as Paths;
import openfl.display.BlendMode;

class SpookyCard extends BackingCard
{
	var scrollTop:FlxBackdrop;
	var scrollLower:FlxBackdrop;

	var glow:FlxSprite;
	var backLines:FlxSprite;

	var confirmAtlas:FlxAtlasSprite;

	public override function enterCharSel():Void
	{
		FlxTween.tween(scrollTop.velocity, {x: 0}, 0.8, {ease: FlxEase.sineIn});
		FlxTween.tween(scrollLower.velocity, {x: 0}, 0.8, {ease: FlxEase.sineIn});
	}

	public override function applyExitMovers(?exitMovers:FreeplayState.ExitMoverData, ?exitMoversCharSel:FreeplayState.ExitMoverData):Void
	{
		super.applyExitMovers(exitMovers, exitMoversCharSel);
		if (exitMovers == null || exitMoversCharSel == null)
			return;

		exitMoversCharSel.set([scrollTop], {
			y: -90,
			speed: 0.8,
			wait: 0.1
		});

		exitMoversCharSel.set([scrollLower], {
			y: -80,
			speed: 0.8,
			wait: 0.1
		});

		exitMoversCharSel.set([backLines], {
			y: -70,
			speed: 0.8,
			wait: 0.1
		});
	}

	public override function init():Void
	{
		FlxTween.tween(pinkBack, {x: 0}, 0.6, {ease: FlxEase.quartOut});
		add(pinkBack);

		confirmTextGlow.blend = BlendMode.ADD;
		confirmTextGlow.visible = false;

		confirmGlow.blend = BlendMode.ADD;

		confirmGlow.visible = false;
		confirmGlow2.visible = false;

		backLines = new FlxSprite(-27, 193).loadGraphic(Paths.image('freeplay/backingCards/spooky/freeplayLines'));
		add(backLines);

		scrollTop = new FlxBackdrop(Paths.image('freeplay/backingCards/spooky/candyRow1'), X, 20);
		scrollTop.setPosition(0, 165);
		scrollTop.velocity.x = -200;
		add(scrollTop);

		scrollLower = new FlxBackdrop(Paths.image('freeplay/backingCards/spooky/candyRow2'), X, 15);
		scrollLower.setPosition(0, 340);
		scrollLower.velocity.x = 200;
		add(scrollLower);

		glow = new FlxSprite(-280, 400).loadGraphic(Paths.image('freeplay/backingCards/spooky/spookyGlow'));
		glow.blend = BlendMode.MULTIPLY;
		add(glow);

		backLines.visible = false;
		scrollTop.visible = false;
		scrollLower.visible = false;
		glow.visible = false;

		confirmAtlas = new FlxAtlasSprite(3, 55, Paths.animateAtlas("freeplay/backingCards/spooky/spooky-confirm"));
		confirmAtlas.visible = false;
		add(confirmAtlas);

		cardGlow.blend = BlendMode.ADD;
		cardGlow.visible = false;
		add(cardGlow);
	}

	override public function confirm():Void
	{
		confirmAtlas.visible = true;
		confirmAtlas.anim.play("");

		FlxTween.color(instance.bgDad, 10 / 24, 0xFFFFFFFF, 0xFF8A8A8A, {
			ease: FlxEase.expoOut,
			onUpdate: function(_)
			{
				instance.angleMaskShader.extraColor = instance.bgDad.color;
			}
		});

		new FlxTimer().start(10 / 24, function(_)
		{
			// shoot
			FlxTween.color(instance.bgDad, 3 / 24, 0xFF343036, 0xFF696366, {
				ease: FlxEase.expoOut,
				onUpdate: function(_)
				{
					instance.angleMaskShader.extraColor = instance.bgDad.color;
				}
			});
		});

		new FlxTimer().start(14 / 24, function(_)
		{
			// shoot
			FlxTween.color(instance.bgDad, 3 / 24, 0xFF27292D, 0xFF686A6F, {
				ease: FlxEase.expoOut,
				onUpdate: function(_)
				{
					instance.angleMaskShader.extraColor = instance.bgDad.color;
				}
			});
		});

		new FlxTimer().start(18 / 24, function(_)
		{
			// shoot
			FlxTween.color(instance.bgDad, 3 / 24, 0xFF2D282D, 0xFF676164, {
				ease: FlxEase.expoOut,
				onUpdate: function(_)
				{
					instance.angleMaskShader.extraColor = instance.bgDad.color;
				}
			});
		});

		new FlxTimer().start(21 / 24, function(_)
		{
			// shoot
			FlxTween.color(instance.bgDad, 3 / 24, 0xFF29292F, 0xFF62626B, {
				ease: FlxEase.expoOut,
				onUpdate: function(_)
				{
					instance.angleMaskShader.extraColor = instance.bgDad.color;
				}
			});
		});

		new FlxTimer().start(24 / 24, function(_)
		{
			// shoot
			FlxTween.color(instance.bgDad, 3 / 24, 0xFF29232C, 0xFF808080, {
				ease: FlxEase.expoOut,
				onUpdate: function(_)
				{
					instance.angleMaskShader.extraColor = instance.bgDad.color;
				}
			});
		});
	}

	var beatFreq:Int = 1;
	var beatFreqList:Array<Int> = [1, 2, 4, 8];

	public override function beatHit(curBeat:Int):Void
	{
		// increases the amount of beats that need to go by to pulse the glow because itd flash like craazy at high bpms.....
		beatFreq = beatFreqList[Math.floor(FreeplayHelpers.BPM / 140)];

		if (curBeat % beatFreq != 0)
			return;
		FlxTween.cancelTweensOf(glow);

		glow.alpha = 1;
		FlxTween.tween(glow, {alpha: 0}, 16 / 24, {ease: FlxEase.quartOut});
	}

	public override function introDone():Void
	{
		pinkBack.color = 0xFF6620AD;

		backLines.visible = true;
		scrollTop.visible = true;
		scrollLower.visible = true;
		glow.visible = true;

		cardGlow.visible = true;
		FlxTween.tween(cardGlow, {alpha: 0, "scale.x": 1.2, "scale.y": 1.2}, 0.45, {ease: FlxEase.sineOut});
	}

	public override function disappear():Void
	{
		FlxTween.color(pinkBack, 0.25, 0xFF98A2F3, 0xFFFFD0D5, {ease: FlxEase.quadOut});

		backLines.visible = false;
		scrollTop.visible = false;
		scrollLower.visible = false;
		glow.visible = false;

		cardGlow.visible = true;
		cardGlow.alpha = 1;
		cardGlow.scale.set(1, 1);
		FlxTween.tween(cardGlow, {alpha: 0, "scale.x": 1.2, "scale.y": 1.2}, 0.25, {ease: FlxEase.sineOut});
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
		var scrollProgress:Float = Math.abs(scrollTop.x % (scrollTop.frameWidth + 20));
	}
}