package misc;

class CustomMainMenuConfig {
    /**
     * If true, Lumen will use a scratch custom menu instead of the default MainMenuState.
     */
    public static var isScratchMenu:Bool = false;

    /**
     * Name of the custom menu script folder to load.
     * Example: "CustomMainMenu"
     * Note: This will look for and create the class by this name.
     */
    public static var mainMenuName:String = "CustomMainMenu";

    /**
     * Resets all menu config to default.
     * Calls this in IntroState.create() or when doing a soft modpack reset.
     */
    public static function reset():Void {
        isScratchMenu = false;
        mainMenuName = "CustomMainMenu";
    }
}
