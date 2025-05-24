package content.baseFNF.scripts.registry.cards;

import mikolka.funkin.FlxAtlasSprite;

var glowTest:FlxSprite;
var glowTestDark:FlxSprite;

var bgBlue:FlxSprite;
var orange1:FlxSprite;
var orange2:FlxSprite;

var anims = ["uzi", "sniper", "rocket launcher", "rifle"];
var animIndex = 0;

function onLoad(name:String,obj:Dynamic) {
    if (name == "glowDark") {
        glowTestDark = obj;
        glowTestDark.loadGraphic(Paths.image('freeplay/backingCards/pico/glow'));
    }
    if (name == "glow") {
        glowTest = obj;
        glowTest.loadGraphic(Paths.image('freeplay/backingCards/pico/glow'));
    }
    if (name == "pinkBack") {
        bgBlue = obj;
        bgBlue.color = 0xFFFFD0D5;
    }
    if (name == "orangeBackShit") {
        orange1 = obj;
    }
    if (name == "alsoOrangeLOL") {
        orange2 = obj;
    }
}

function onIntroDone(){
    // BOTTOM SCROLLING LAYER (Static Image)
    visualUtils.addBGImageLayer("scrollBottom", "freeplay/backingCards/pico/lowerLoop", 110, 0, 406, false, 1.0);
    
    // MIDDLE SCROLLING LAYER
    visualUtils.addBGImageLayer("scrollMiddle", "freeplay/backingCards/pico/middleLoop", -220, 0, 346, false, 1.0);

    // TOP SCROLLING LAYER (Animated)
    visualUtils.addBGImageLayer("scrollTop", "freeplay/backingCards/pico/topLoop", -220, 0, 80, false, 1.0, [
        {prefix: "uzi", fps: 24},
        {prefix: "sniper", fps: 24},
        {prefix: "rocket launcher", fps: 24},
        {prefix: "rifle", fps: 24},
        {prefix: "base", fps: 24}
    ], "base");

    bgBlue.color = 0xFF98A2F3;
    orange1.color = 0xFF98A2F3;
    orange2.color = 0xFF98A2F3;

    visualUtils.addBGImageLayer("blueBar", "freeplay/backingCards/pico/blueBar", 0, 0, 239, false, 0.5);
    visualUtils.setBGLayerBlending("blueBar", BlendMode.MULTIPLY);
}

function onBeatHit(curBeat){
    // Cycle through animations every 3 beats
    if (curBeat % 3 == 0) {
        animIndex = (animIndex + 1) % anims.length;
        visualUtils.playBGLayerAnimation("scrollTop", anims[animIndex]);
    }

}

function onDisappear(){
    visualUtils.removeObject("scrollBottom");
    visualUtils.removeObject("scrollMiddle");
    visualUtils.removeObject("scrollTop");
    visualUtils.removeObject("blueBar");
    bgBlue.color = 0xFFFFD0D5;
    orange1.color = 0xFFFFD0D5;
    orange2.color = 0xFFFFD0D5;
}

function onConfirm(){
    visualUtils.removeObject("scrollBottom");
    visualUtils.removeObject("scrollMiddle");
    visualUtils.removeObject("scrollTop");
    visualUtils.removeObject("blueBar");
}