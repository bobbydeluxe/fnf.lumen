// HScript Menu State Example for Lumen Engine

var options = ["Story Mode", "Freeplay", "Credits", "Options"];
var menuItems:Array<FlxText> = [];
var curSelected = 0;

function onCreate() {
    // Pull from persistent memory bank
    if (Bank.has("menu_selection")) {
        curSelected = Bank.get("menu_selection");
    }

    for (i in 0...options.length) {
        var item = new FlxText(0, 150 + i * 50, FlxG.width, options[i]);
        item.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, "center");
        item.ID = i;
        menuItems.push(item);
        add(item);
    }

    updateSelectionVisuals();
}

function updateSelectionVisuals() {
    for (item in menuItems) {
        item.color = (item.ID == curSelected) ? FlxColor.PINK : FlxColor.WHITE;
    }
}

function onUpdate(elapsed:Float) {
    if (controls.UI_UP_P) {
        curSelected = (curSelected - 1 + options.length) % options.length;
        updateSelectionVisuals();
    }

    if (controls.UI_DOWN_P) {
        curSelected = (curSelected + 1) % options.length;
        updateSelectionVisuals();
    }

    if (controls.ACCEPT) {
        Bank.set("menu_selection", curSelected);
        switch (curSelected) {
            // do ur shit here
        }
    }
}
