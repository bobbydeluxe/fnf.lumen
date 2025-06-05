// Snow effect for the main menu
// credits to SadeceNicat for this

import states.StoryMenuState;

var snowArray:Array<FlxSprite> = [];
var menuItemsBack:FlxTypedGroup<FlxSprite>;
var bgAga:FlxSprite;

function onCreate() {
    game.hybridEngineMenu = false;

    game.optionShit = ["story_mode","mods"];
    game.leftOption = null;
    game.rightOption = null;
    game.menuX = 175;
}

function onLoad(name:String,obj:Dynamic) {
    if (name == "bg") {
        bgAga = obj;
        bgAga.loadGraphic(Paths.image("menuDesat"));
    }
    if (name == "menuItemsBack") {
        menuItems = obj;
        var timer:FlxTimer = new FlxTimer();
		timer.start(0.04, function () {
            var scaleXY:Float = FlxG.random.float(0.1,0.7);
            var sprAga:FlxSprite = new FlxSprite(FlxG.random.float(-200,1280),-100);
            sprAga.loadGraphic(Paths.image("justBf")); // we dont have snow, so best bet is a random bf sticker
            sprAga.velocity.y = FlxG.random.float(200,355);
            sprAga.velocity.x = FlxG.random.float(0,200);
            sprAga.scrollFactor.set(0,0);
            sprAga.scale.set(scaleXY,scaleXY);
            menuItems.add(sprAga);
            snowArray.push(sprAga);
        }, 0);
    }
}

function onUpdate(elapsed:Float) {
    for (spr in snowArray) {
        if (spr) {
        spr.angle += 155 * elapsed;
        if (spr.y >= 720) {
            spr.destroy();
        }
        }
    }
}

function onUpdatePost() {
    bgAga.color = FlxColor.fromRGB(200,200,200);
}

function onCreateMenuItems(num:Int,MenuItem:Dynamic) {
    MenuItem.y -= 40;
}

function onStart(op:String) {
    if (op == "story_mode") {
        game.triggerEvent("LoadSong","christmas",1);
        game.cancelLoad = true;
    }
}