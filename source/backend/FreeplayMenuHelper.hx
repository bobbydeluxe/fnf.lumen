package backend;

import states.MainMenuState;
import states.CustomState;
import misc.CustomMainMenuConfig;

// lumen engine class, used for freeplay so i can support custom main menus easier

class FreeplayMenuHelper {
    public static function getMainMenu(playRankAnim:Bool = false):MusicBeatState {
        if (CustomMainMenuConfig.isScratchMenu)
        {
            FlxG.save.data.currentState = CustomMainMenuConfig.mainMenuName;
            return new CustomState(null);
        }
        else
            return new MainMenuState(null, playRankAnim);
    }
}
