function onCreate()
    -- PRECACHE
    precacheSound('fnf_loss_sfx-pixel')

	-- CHARACTER
	setPropertyFromClass('substates.GameOverSubstate', 'characterName', 'bf-pixel-dead')
	
	-- SOUNDS/MUSICS
	setPropertyFromClass('substates.GameOverSubstate', 'deathSoundName', 'fnf_loss_sfx-pixel') --file goes inside sounds/ folder
	setPropertyFromClass('substates.GameOverSubstate', 'loopSoundName', 'gameOver-pixel') --file goes inside music/ folder
	setPropertyFromClass('substates.GameOverSubstate', 'endSoundName', 'gameOverEnd-pixel') --file goes inside music/ folder
end