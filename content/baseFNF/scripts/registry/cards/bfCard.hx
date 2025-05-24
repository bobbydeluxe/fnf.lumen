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
    moreWays = visualUtils.addBackingText("moreWays", 0, 160, text2, FlxG.width, true, 43);
    moreWays.funnyColor = 0xFFFFF383;
    moreWays.speed = 6.8;

    funnyScroll = visualUtils.addBackingText("funnyScroll", 0, 220, text1, FlxG.width / 2, false, 60);
    funnyScroll.funnyColor = 0xFFFF9963;
    funnyScroll.speed = -3.8;

    txtNuts = visualUtils.addBackingText("txtNuts", 0, 285, text3, FlxG.width / 2, true, 43);
    txtNuts.speed = 3.5;

    funnyScroll2 = visualUtils.addBackingText("funnyScroll2", 0, 335, text1, FlxG.width / 2, false, 60);
    funnyScroll2.funnyColor = 0xFFFF9963;
    funnyScroll2.speed = -3.8;

    moreWays2 = visualUtils.addBackingText("moreWays2", 0, 397, text2, FlxG.width, true, 43);
    moreWays2.funnyColor = 0xFFFFF383;
    moreWays2.speed = 6.8;

    funnyScroll3 = visualUtils.addBackingText("funnyScroll3", 0, 450, text1, FlxG.width / 2, false, 60);
    funnyScroll3.funnyColor = 0xFFFEA400;
    funnyScroll3.speed = -3.8;
}

function onConfirm() {
    visualUtils.removeBackingText("moreWays");
    visualUtils.removeBackingText("funnyScroll");
    visualUtils.removeBackingText("txtNuts");
    visualUtils.removeBackingText("funnyScroll2");
    visualUtils.removeBackingText("moreWays2");
    visualUtils.removeBackingText("funnyScroll3");
}

function onDisappear() {
    visualUtils.removeBackingText("moreWays");
    visualUtils.removeBackingText("funnyScroll");
    visualUtils.removeBackingText("txtNuts");
    visualUtils.removeBackingText("funnyScroll2");
    visualUtils.removeBackingText("moreWays2");
    visualUtils.removeBackingText("funnyScroll3");
}