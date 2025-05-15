/* FNF Lumen Engine - Story Mode Fakeout Example [PULL]
 * by bobbyDX
 * This replicates the Blazin' song fakeout in Weekend 1 of the base game, now in Lumen.
 * place this file in `mods/<mod_name>/scripts/states/storymenu/` as a `.hx` file
 */

import states.StoryMenuState;
import backend.WeekData;
import backend.Highscore;

function onChangeWeek(weekFileName) {
    // Check if the selected week is Weekend 1 and if it has NOT been completed
    if (weekFileName == "wknd1" 
        && (!StoryMenuState.weekCompleted.exists("wknd1") 
        || !StoryMenuState.weekCompleted.get("wknd1"))) {
        
        // Check if the high score for wknd1 is 0
        var highScore = Highscore.getWeekScore(weekFileName, StoryMenuState.curDifficulty);
        if (highScore == 0) {
            // Get the WeekData for wknd1
            var weekData = WeekData.weeksLoaded.get(weekFileName);

            // Update the songs list for wknd1
            weekData.songs = [
                ["Darnell", 1],
                ["Lit Up", 1],
                ["2hot", 1],
                // Blazin' needs to be put in the week JSON
            ];

            //trace("Custom tracklist for " + weekFileName + " applied!");
        } else {
            //trace("High score for " + weekFileName + " is above 0. Default tracklist loaded.");
        }
    } else {
        //trace("Default tracklist for " + weekFileName + " loaded.");
    }
}