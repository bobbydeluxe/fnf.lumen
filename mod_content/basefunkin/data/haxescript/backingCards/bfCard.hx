import mikolka.vslice.freeplay.BGScrollingText;

var moreWays:BGScrollingText;
var funnyScroll:BGScrollingText;
var txtNuts:BGScrollingText;
var funnyScroll2:BGScrollingText;
var moreWays2:BGScrollingText;
var funnyScroll3:BGScrollingText;
var text1:String;
var text2:String;
var text3:String;

function onDJDataSent(t1:String, t2:String, t3:String) {
    text1 = t1;
    text2 = t2;
    text3 = t3;
}

function onIntroDone() {
    // Add scrolling texts
    moreWays = hxvisual.addBackingText("moreWays", 0, 160, text2, FlxG.width, true, 43);
    moreWays.funnyColor = 0xFFFFF383;
    moreWays.speed = 6.8;

    funnyScroll = hxvisual.addBackingText("funnyScroll", 0, 220, text1, FlxG.width / 2, false, 60);
    funnyScroll.funnyColor = 0xFFFF9963;
    funnyScroll.speed = -3.8;

    txtNuts = hxvisual.addBackingText("txtNuts", 0, 285, text3, FlxG.width / 2, true, 43);
    txtNuts.speed = 3.5;

    funnyScroll2 = hxvisual.addBackingText("funnyScroll2", 0, 335, text1, FlxG.width / 2, false, 60);
    funnyScroll2.funnyColor = 0xFFFF9963;
    funnyScroll2.speed = -3.8;

    moreWays2 = hxvisual.addBackingText("moreWays2", 0, 397, text2, FlxG.width, true, 43);
    moreWays2.funnyColor = 0xFFFFF383;
    moreWays2.speed = 6.8;

    funnyScroll3 = hxvisual.addBackingText("funnyScroll3", 0, 450, text1, FlxG.width / 2, false, 60);
    funnyScroll3.funnyColor = 0xFFFEA400;
    funnyScroll3.speed = -3.8;
}

function onConfirm() {
    hxvisual.removeBackingText("moreWays");
    hxvisual.removeBackingText("funnyScroll");
    hxvisual.removeBackingText("txtNuts");
    hxvisual.removeBackingText("funnyScroll2");
    hxvisual.removeBackingText("moreWays2");
    hxvisual.removeBackingText("funnyScroll3");
}

function onDisappear() {
    hxvisual.removeBackingText("moreWays");
    hxvisual.removeBackingText("funnyScroll");
    hxvisual.removeBackingText("txtNuts");
    hxvisual.removeBackingText("funnyScroll2");
    hxvisual.removeBackingText("moreWays2");
    hxvisual.removeBackingText("funnyScroll3");
}