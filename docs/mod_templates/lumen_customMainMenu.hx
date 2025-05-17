/* FNF Lumen Engine - Custom Main Menu
 * by bobbyDX
 * to activate this, place this file in `mods/<mod_name>/scripts/states/custom/<mainMenuName>/` as a `.hx` file
 * you'll need an hscript in `mods/<mod_name>/scripts/states/intro/` that makes this the main menu
 * in the intro state script, you need to set mainMenuConfig.isScratchMenu to true and then also change mainMenuConfig.mainMenuName
 * the mainMenuName will dictate in what folder under the custom state scripts folder will the main menu be
 */


import flixel.addons.display.FlxBackdrop;
import flixel.addons.display.FlxGridOverlay;
import flixel.effects.FlxFlicker;
import mikolka.vslice.freeplay.BGScrollingText;

var options:Array<String> = ['Story Mode', 'Freeplay', 'Mods', 'Awards', 'Options', 'Credits'];
var optionTexts:Array<FlxText> = [];
var curSelected:Int = 0;
var optionChosen:Bool = false;

function onCreate() {
    var startY:Float = 150;
    var spacing:Float = 70; // Adjusted spacing for better alignment
    var posX:Float = 50;

    bg = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
    bg.color = 0xFF252525;
    bg.antialiasing = ClientPrefs.data.antialiasing;
    add(bg);
    bg.screenCenter();

    var grid:FlxBackdrop = new FlxBackdrop(FlxGridOverlay.createGrid(80, 80, 160, 160, true, 0x83657CFF, 0x8365BAFF));
    grid.velocity.set(40, 40);
    grid.alpha = 0;
    FlxTween.tween(grid, {alpha: 1}, 0.5, {ease: FlxEase.quadOut});
    add(grid);

    for (i in 0...options.length) {
        var txt = new FlxText(posX, startY + i * spacing, 0, options[i]);
        txt.setFormat(null, 28, FlxColor.WHITE, "left");
        optionTexts.push(txt);
        add(txt);
    }

    FlxG.camera.bgColor = FlxColor.BLACK;

    var lumenScriptTXT = new BGScrollingText(0, 660, "made with lumen engine  |", FlxG.width / 2, true, 30);
    lumenScriptTXT.funnyColor = 0xfffff56d;
    add(lumenScriptTXT);

    updateSelection();
}

function updateSelection() {
    for (i in 0...optionTexts.length) {
        if (i == curSelected) {
            optionTexts[i].setFormat(null, 28, 0xFFFFA070, "left"); // light orange
            optionTexts[i].x = 70; // move right when selected
        } else {
            optionTexts[i].setFormat(null, 28, FlxColor.WHITE, "left");
            optionTexts[i].x = 50; // normal position
        }
    }
}

function onUpdate(elapsed:Float) {
    if (controls.UI_UP_P) {
        if (optionChosen == false)
        {
            curSelected = (curSelected - 1 + options.length) % options.length;
            updateSelection();
        }
        
    }
    if (controls.UI_DOWN_P) {
        if (optionChosen == false)
        {
            curSelected = (curSelected + 1) % options.length;
            updateSelection();
        }
    }
    if (controls.BACK) {
        triggerEvent("ChangeState", "titlescreen");
    }
    if (controls.ACCEPT && !optionChosen) {
        optionChosen = true; // prevent multiple triggers
        FlxG.sound.play(Paths.sound('confirmMenu')); // play the sound immediately
        FlxFlicker.flicker(optionTexts[curSelected], 1, 0.06, false, false);
        
        delayTimer = new FlxTimer().start(1, function(tmr:FlxTimer) {
            // substate glitch prevention
            optionChosen = false;
            optionTexts[curSelected].visible = true;

            // switch logic
            switch (curSelected) {
                case 0:
                    triggerEvent("ChangeState", "storymode");
                case 1:
                    triggerEvent("ChangeState", "freeplay");
                case 2:
                    triggerEvent("ChangeState", "mods");
                case 3:
                    triggerEvent("ChangeState", "awards");
                case 4:
                    triggerEvent("ChangeState", "options");
                case 5:
                    triggerEvent("ChangeState", "credits");
            }
        });
    }
}