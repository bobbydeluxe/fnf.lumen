local characterType = ''
local characterName = ''
local offsetData = {0, 0}
local propertyTracker = {
    {'x', nil},
    {'y', nil},
    {'color', nil},
    {'scrollFactor.x', nil},
    {'scrollFactor.y', nil},
    {'angle', nil},
    {'alpha', nil},
    {'antialiasing', nil},
    {'visible', nil}
}

--[[ 
    Self explanatory, creates the speaker based on if if's attached to a character or not,
    and the inputted offsets. Wait, why did I explain it still?
    Because it also sets up everything needed for the script to work, duh.
]]
function createSpeaker(attachedCharacter, offsetX, offsetY)
    characterName = attachedCharacter
    offsetData = {offsetX, offsetY}
    if getCharacterType(attachedCharacter) ~= nil then
        characterType = getCharacterType(attachedCharacter)
    end
    
    makeFlxAnimateSprite('AbotSpeaker')
    loadAnimateAtlas('AbotSpeaker', 'abot/abotSystem')
    if characterType ~= '' then
        setObjectOrder('AbotSpeaker', getObjectOrder(characterType..'Group'))
    end
    addLuaSprite('AbotSpeaker')

    for property = 1, 2 do
        if characterType ~= '' then
            propertyTracker[property][2] = getProperty(characterType..'.'..propertyTracker[property][1])
            setAbotSpeakerProperty(propertyTracker[property][1], propertyTracker[property][2])
        else
            propertyTracker[property][2] = getProperty('AbotSpeaker.'..propertyTracker[property][1])
            setProperty('AbotSpeaker.'..propertyTracker[property][1], offsetData[property])
        end
    end

    if characterName ~= '' then
        if _G[characterType..'Name'] ~= characterName then
            destroySpeaker()
        end
    end
end

-- Self explanatory again.
function destroySpeaker()
    runHaxeCode([[
        game.variables.get('AbotSpeaker').destroy();
        game.variables.remove('AbotSpeaker');
    ]])
end

-- This is to prevent the speaker from still appearing when the attached character's gone.
function onEvent(eventName, value1, value2, strumTime)
    if eventName == 'Change Character' then
        if getCharacterType(value2) == characterType and value2 ~= characterName then
            destroySpeaker()
        elseif characterName ~= '' then
            createSpeaker(characterName, offsetData[1], offsetData[2])
        end
    end
end

function onCountdownTick(swagCounter)
    --[[
        Makes the speaker bop at the same time as the character.
        Ex: If the character only bops their head when the beat is even,
        then the speaker will also do the same.
        This will only work during the countdown.
    ]]
    if characterType == 'gf' then
        characterSpeed = getProperty('gfSpeed')
    else
        characterSpeed = 1
    end
    if characterType ~= '' then
        danceEveryNumBeats = getProperty(characterType..'.danceEveryNumBeats')
    else
        danceEveryNumBeats = 1
    end
    if swagCounter % (danceEveryNumBeats * characterSpeed) == 0 then
        playAnim('AbotSpeaker', '', true, false, 1)
    end
end

function onBeatHit()
    --[[
        Same here, but it works for the entirety of the song.
    ]]
    if characterType == 'gf' then
        characterSpeed = getProperty('gfSpeed')
    else
        characterSpeed = 1
    end
    if characterType ~= '' then
        danceEveryNumBeats = getProperty(characterType..'.danceEveryNumBeats')
    else
        danceEveryNumBeats = 1
    end
    if curBeat % (danceEveryNumBeats * characterSpeed) == 0 then
        playAnim('AbotSpeaker', '', true, false, 1)
    end
end

function onUpdatePost(elapsed)
    for property = 1, #propertyTracker do
        if characterType ~= '' then
            if propertyTracker[property][2] ~= getProperty(characterType..'.'..propertyTracker[property][1]) then
                propertyTracker[property][2] = getProperty(characterType..'.'..propertyTracker[property][1])
                setAbotSpeakerProperty(propertyTracker[property][1], propertyTracker[property][2])
            end
        else
            if propertyTracker[property][2] ~= getProperty('AbotSpeaker.'..propertyTracker[property][1]) then
                propertyTracker[property][2] = getProperty('AbotSpeaker.'..propertyTracker[property][1])
                setAbotSpeakerProperty(propertyTracker[property][1], propertyTracker[property][2])
            end
        end
    end
    --[[
        These make it so the animations stop when they're supposed to be,
        instead of looping endlessly.
    ]] 
    if getProperty('AbotSpeaker.anim.curFrame') >= 15 then
        pauseAnim('AbotSpeaker')
    end
    -- This is how we control the animations' speed depending on the 'playbackRate' for Atlas Sprites.
    setProperty('AbotSpeaker.anim.framerate', 24 * playbackRate)
end

--[[
    This function is useful if you change any of the properties of the attached character, 
    or the speaker itself if it's not attached to any character, instead of changing it manually. 
    This only works for the properties present in 'propertyTracker', though.

    WARNING: Do not use this function if you want to change Abot Speaker's properties,
    as it is only meant to be used inside this script.
    Instead, use the 'setProperty' function as usual.
    Examples:
    setProperty('boyfriend.alpha', 0.5)     --> If attached to the BF character type.
    setProperty('dad.alpha', 0.5)           --> If attached to the Dad character type.
    setProperty('gf.alpha', 0.5)            --> If attached to the GF character type.
    setProperty('AbotSpeaker.alpha', 0.5)   --> If not attached to any character type.

    'doTween' functions also work the same way. 
]]
function setAbotSpeakerProperty(property, value)
    if property == 'x' then
        if characterType ~= '' then
            value = value + offsetData[1]
            setProperty('AbotSpeaker.'..property, value - 100)
        end
    elseif property == 'y' then
        if characterType ~= '' then
            value = value + offsetData[2]
            setProperty('AbotSpeaker.'..property, value + 316)
        end
    else
        if characterType ~= '' then
            setProperty('AbotSpeaker.'..property, value)
        end
    end
end

--[[ Old version of the function above.
function updateSpeaker(property)
    if property == 'x' then
        setProperty('AbotSpeaker.'..property, offset.x - 100)
        for bar = 1, 7 do
            setProperty('AbotSpeakerVisualizer'..bar..'.'..property, offset.x + 100 + visualizerOffsetX(bar))
        end
        setProperty('AbotSpeakerBG.'..property, offset.x + 65)
        setProperty('AbotEyes.'..property, offset.x - 60)
        setProperty('AbotPupils.'..property, offset.x - 607)
    elseif property == 'y' then
        setProperty('AbotSpeaker.'..property, offset.y + 316)
        for bar = 1, 7 do
            setProperty('AbotSpeakerVisualizer'..bar..'.'..property, offset.y + 400 + visualizerOffsetY(bar))
        end
        setProperty('AbotSpeakerBG.'..property, offset.y + 347)
        setProperty('AbotEyes.'..property, offset.y + 567)
        setProperty('AbotPupils.'..property, offset.y - 176)
    elseif characterType ~= '' then
        setProperty('AbotSpeaker.'..property, getProperty(characterType..'.'..property))
        for bar = 1, 7 do
            setProperty('AbotSpeakerVisualizer'..bar..'.'..property, getProperty(characterType..'.'..property))
        end
        setProperty('AbotSpeakerBG.'..property, getProperty(characterType..'.'..property))
        setProperty('AbotEyes.'..property, getProperty(characterType..'.'..property))
        setProperty('AbotPupils.'..property, getProperty(characterType..'.'..property))
    end
end
]]

--[[
    This handles the offsets for each visualizer bar.
    Again, it is to make things automatic instead of doing everything manually.
]]
function pauseAnim(object)
    runHaxeCode("game.getLuaObject('"..object.."').anim.pause();")
end

function getCharacterType(characterName)
    if boyfriendName == characterName then
        return 'boyfriend'
    elseif dadName == characterName then
        return 'dad'
    elseif gfName == characterName then
        return 'gf'
    end
end