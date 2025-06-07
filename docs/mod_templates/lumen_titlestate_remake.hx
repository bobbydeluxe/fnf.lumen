/* FNF Lumen Engine - Title Screen Recreation
 * by bobbyDX
 * place this file in `mods/<mod_name>/scripts/states/titlestate/` as a `.hx` file
 */

// === GLOBALS ===
var ngLogo:FlxSprite = null;
var introText:Array<Alphabet> = [];
var sickBeats:Int = 0;
var introSkipped:Bool = false;

var allWackys:Array<Array<String>> = getIntroTextShit();
var curWacky:Array<String> = allWackys[FlxG.random.int(0, allWackys.length - 1)];
var lastWacky:Array<String> = curWacky;

// === OPTIONAL: Call this to get a new line that's different from the last
// Uncomment below to allow dynamic regeneration later
/*
function regenerateWacky():Array<String> {
	var fresh:Array<String> = curWacky;
	if (allWackys.length > 1) {
		while (fresh == lastWacky) {
			fresh = allWackys[FlxG.random.int(0, allWackys.length - 1)];
		}
	}
	lastWacky = fresh;
	return fresh;
}
*/

function onCreatePost() {
	// Make sure the original title text protocol is not used so we can use our own
	game.cancelLoad = true;

	// Set up the newgrounds logo
	ngLogo = new FlxSprite(0, FlxG.height * 0.52);

	if (FlxG.random.bool(1))
	{
		ngLogo.loadGraphic(Paths.image('newgrounds_logo_classic'));
	}
	else if (FlxG.random.bool(30))
	{
		ngLogo.loadGraphic(Paths.image('newgrounds_logo_animated'), true, 600);
		ngLogo.animation.add('idle', [0, 1], 4);
		ngLogo.animation.play('idle');
		ngLogo.setGraphicSize(Std.int(ngLogo.width * 0.55));
	}
	else
	{
		ngLogo.loadGraphic(Paths.image('newgrounds_logo'));
		ngLogo.setGraphicSize(Std.int(ngLogo.width * 0.8));
	}

	ngLogo.updateHitbox();
	ngLogo.x = (FlxG.width - ngLogo.width) / 2;
	ngLogo.antialiasing = true;
	ngLogo.visible = false;
	add(ngLogo);

	// Uncomment below if you want to change press-start text properties
	// game.titleTextColors = [0xFF33FFFF, 0xFF3333CC];
	// game.titleTextAlphas = [1, .64];
}

function onBeatTexts(beat:Int) {
	sickBeats = beat;

	switch (beat) {
		case 1:
			FlxG.sound.playMusic(Paths.music("freakyMenu"), 0);
			FlxG.sound.music.fadeIn(4, 0, 0.7);

		case 2:
			createCoolText(["Lumen Engine by"]);

		case 4:
			addMoreText("bobbyDX");

		case 5:
			deleteCoolText();

		case 6:
			createCoolText(["Not associated", "with"], -40);
			// negative y offset brings it up for some reason
			// haxeflixel's just weird like that

		case 8:
			addMoreText("newgrounds", -40);
			if (!introSkipped) {
				ngLogo.visible = true;
			}

		case 9:
			deleteCoolText();
			ngLogo.visible = false;

		case 10:
			// curWacky = regenerateWacky(); // Uncomment this to cycle a new intro line
			createCoolText([curWacky[0]]);

		case 12:
			addMoreText(curWacky[1]);

		case 13:
			deleteCoolText();

		case 14:
			createCoolText(["Friday"]);

		case 15:
			addMoreText("Night");

		case 16:
			addMoreText("Funkin");

		case 17:
			skipIntro();
	}
}

function onSkipIntro() {
	if (!introSkipped) {
		introSkipped = true;
	}
}