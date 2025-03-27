local doDialogue = true
local soundPlay = false
local langCode = getPropertyFromClass('backend.ClientPrefs', 'data.language')
local langCodeFinal

function onStartCountdown()
	if langCode == 'en-US' then
        langCodeFinal = ""
    else
        langCodeFinal = "-"..langCode
    end

	if soundPlay == false then

        if isStoryMode and not seenCutscene then
            playSound('spiritReveal', 1, 'reveal', false)
        end
        playSound('dialogueBGM/LunchboxScary', 1, 'bgm', true)

        if isStoryMode and not seenCutscene then
            makeLuaSprite('overlay')
            makeGraphic('overlay', screenWidth, screenHeight, 'c41425')
            setProperty('overlay.visible', true)
            setProperty('overlay.alpha', 0.25)
            setObjectCamera('overlay', 'hud')
            addLuaSprite('overlay', true)
        end

        soundPlay = true
    else
        soundFadeOut('bgm', 1, 0)

        if isStoryMode and not seenCutscene then
            removeLuaSprite('overlay')
        end
    end

	if doDialogue and not seenCutscene and isStoryMode and checkFileExists('data/songs/'..string.lower(string.gsub(songName, "%s+", "-"))..'/dialogue'..langCodeFinal..'.json') then
		setProperty('inCutscene', true)
		runTimer('startDialogue', 2)
		doDialogue = false
		return Function_Stop
	end

	return Function_Continue
end

function onSongStart()
    stopSound('bgm')
    if isStoryMode and not seenCutscene then
        removeLuaSprite('overlay')
    end
end