--script ripped from skellix's hud script [https://gamebanana.com/mods/534209]
--please credit skellix when using this, and preferrably me too [bobbyDX]

local creditsActive = true

function onCreatePost()
    if creditsActive == true then
        --Create Credits Crap
        makeLuaSprite('creditsRibbon', '', -1280, 300)
        makeGraphic('creditsRibbon', 1280, 150, '000000')
        setToCam('creditsRibbon', 'camOther')
        setProperty('creditsRibbon.alpha', 0.65)
        addLuaSprite('creditsRibbon')

        makeLuaText('songNameCredit', 'Now Playing -  ' .. songName, 1280, -1280, 310)
        setToCam('songNameCredit', 'camOther')
        addLuaText('songNameCredit')
        setTextAlignment('songNameCredit', 'center')
        setTextSize('songNameCredit', 45)

        --Get Credits Info
        coolPeople = 'idk'
        if string.lower(difficultyName) == 'normal' then
            coolPeople = parseString(getTextFromFile('data/songs/'..songPath..'/credits/credits.txt'), '%s')
        else
            coolPeople = parseString(getTextFromFile('data/songs/'..songPath..'/credits/credits-'..string.lower(string.gsub(difficultyName, "%s+", "-"))..'.txt'), '%s')
        end

        makeLuaText('credit', 'Composer: '..string.gsub(coolPeople[1], "_", " ")
        ..' | Charter: '..string.gsub(coolPeople[2], "_", " ")
        , 1280, -1280, 400)
        setToCam('credit', 'camOther')
        addLuaText('credit')
        setTextAlignment('credit', 'center')

        if string.len(getProperty('credit.text')) > 68 then
            setTextSize('credit', 30 - (0.2*(string.len(getProperty('credit.text')) - 68)))
        else
            setTextSize('credit', 30)
        end
    end
end

function onTimerCompleted(n)
    if creditsActive == true then
        if n == 'titleDelay' then
            doTweenX('creditSongOut', 'songNameCredit', 1280, 0.75,'circIn')
            doTweenX('creditOut', 'credit', 1280, 0.5,'circIn')
        end
    end
end

function onTweenCompleted(n)
    if creditsActive == true then
        if n == 'creditsOpen' then
            doTweenX('creditSongIn', 'songNameCredit', 0, 0.5,'circOut')
            doTweenX('creditIn', 'credit', 0, 0.75,'circOut')
            runTimer('titleDelay', 3)
        end

        if n == 'creditSongOut' then
            doTweenX('creditsClose', 'creditsRibbon', 1280, 0.5,'circOut')
        end

        if n == 'creditsClose' then
            setProperty('creditsRibbon.x', -1280)
        end
    end
end

function onSongStart()
    if creditsActive == true then
        -- Handle Credits Tab
        if coolPeople == 'idk' then
            noCreds = true
        end

        if not itsOver == true and not noCreds == true then
            doTweenX('creditsOpen', 'creditsRibbon', 0, 0.5,'circIn')
        end
    end
end

function parseString (inputstr, sep)
    if sep == nil then
            sep = '%s'
    end
    local t={}
    for str in string.gmatch(inputstr, '([^'..sep..']+)') do
            table.insert(t, str)
    end
    return t
end

function setToCam(sprite,cam)
    if version == '1.0' then
        setProperty(sprite..'.camera',instanceArg(cam), false, true)
    else
        setObjectCamera(sprite,cam)
    end
end