function onCreate()
    -- PRECACHE
    precacheSound('fnf_loss_sfx-pico-gutpunch')

	-- CHARACTER
	setPropertyFromClass('substates.GameOverSubstate', 'characterName', 'pico-blazin')
	
	-- SOUNDS/MUSICS
	setPropertyFromClass('substates.GameOverSubstate', 'deathSoundName', 'fnf_loss_sfx-pico-gutpunch') --file goes inside sounds/ folder
	setPropertyFromClass('substates.GameOverSubstate', 'loopSoundName', 'gameOver-pico') --file goes inside music/ folder
	setPropertyFromClass('substates.GameOverSubstate', 'endSoundName', 'gameOverEnd-pico') --file goes inside music/ folder
end