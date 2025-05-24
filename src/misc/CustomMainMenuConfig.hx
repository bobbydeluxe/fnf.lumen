package misc;

class CustomMainMenuConfig {
    /**
     * DOCUMENTATION TBA
     * Originally supposed to be for the main menu, i'm expanding this for story mode and freeplay states, as there are multiple transition calls for those
     */
    public static var isScratchMenu:Array<Bool> = [false, false, false];
    public static var mainMenuName:Array<String> = ["CustomMainMenu", "CustomStoryMenu", "CustomFreeplay"];

    /**
     * Resets all menu config to default.
     * Calls this in IntroState.create() or when doing a soft modpack reset.
     */
    public static function reset():Void {
        isScratchMenu = [false, false, false];
        mainMenuName = ["CustomMainMenu", "CustomStoryMenu", "CustomFreeplay"];
    }
}
