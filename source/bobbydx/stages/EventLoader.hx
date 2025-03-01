package bobbydx.stages;

import mikolka.stages.standard.*;
import haxe.ds.List;
#if !LEGACY_PSYCH
import states.MainMenuState;
#end

class EventLoader extends BaseStage {
    public static function addstage(name:String) {
        new TankmenUsableStage();

        switch (name)
        {
            case 'stage': new StageWeek1(); 						// Week 1
            case 'tank': new Tank();								// Week 7
        }
    } 
}
