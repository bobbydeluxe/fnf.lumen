// Story Mode Fakeout Song List Script
//place this file in `mods/<mod_name>/scripts/states/storymenu/` as a `.hx` file

import states.StoryMenuState;
import backend.WeekData;
import backend.Highscore;

function onChangeWeek(weekFileName) {
    if (weekFileName == "wknd1") {
        var completed = StoryMenuState.weekCompleted.exists("wknd1") && StoryMenuState.weekCompleted.get("wknd1");
        var highScore = Highscore.getWeekScore(weekFileName, StoryMenuState.curDifficulty);
        var weekData = WeekData.weeksLoaded.get(weekFileName);

        if (completed && highScore > 0) {
            // Completed: show all tracks including Blazin
            weekData.songs = [
                ["Darnell", 1],
                ["Lit Up", 1],
                ["2hot", 1],
                ["Blazin", 1]
            ];
        } else if (!completed && highScore == 0) {
            // Not completed: show only first three tracks
            weekData.songs = [
                ["Darnell", 1],
                ["Lit Up", 1],
                ["2hot", 1]
            ];
        }
        // else: leave weekData.songs as default
    }
}