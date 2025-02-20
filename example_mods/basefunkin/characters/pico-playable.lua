function onCreate()
    -- PRECACHE
    precacheSound('fnf_loss_sfx-pico')
    addCharacterToList('pico-explosion-dead', 'boyfriend')

	-- CHARACTER
	setPropertyFromClass('substates.GameOverSubstate', 'characterName', 'pico-dead')
	
	-- SOUNDS/MUSICS
	setPropertyFromClass('substates.GameOverSubstate', 'deathSoundName', 'fnf_loss_sfx-pico') --file goes inside sounds/ folder
	setPropertyFromClass('substates.GameOverSubstate', 'loopSoundName', 'gameOver-pico') --file goes inside music/ folder
	setPropertyFromClass('substates.GameOverSubstate', 'endSoundName', 'gameOverEnd-pico') --file goes inside music/ folder
end