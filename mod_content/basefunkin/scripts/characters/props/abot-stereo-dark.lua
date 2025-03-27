local characterType = ''
local characterName = ''
local looksAtPlayer = true
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

    makeLuaSprite('AbotSpeakerDarkBG', 'abot/stereoBG')
    if characterType ~= '' then
        setObjectOrder('AbotSpeakerDarkBG', getObjectOrder(characterType..'Group'))
    end
    addLuaSprite('AbotSpeakerDarkBG')

    for bar = 1, 7 do
        makeAnimatedLuaSprite('AbotSpeakerDarkVisualizer'..bar, 'abot/aBotViz')
        addAnimationByPrefix('AbotSpeakerDarkVisualizer'..bar, 'idle', 'viz'..bar, 24, false)
        if characterType ~= '' then
            setObjectOrder('AbotSpeakerDarkVisualizer'..bar, getObjectOrder(characterType..'Group'))
        end
        addLuaSprite('AbotSpeakerDarkVisualizer'..bar)

        setSpriteShader('AbotSpeakerDarkVisualizer'..bar, 'adjustColor')
        setShaderFloat('AbotSpeakerDarkVisualizer'..bar, 'hue', -26)
        setShaderFloat('AbotSpeakerDarkVisualizer'..bar, 'saturation', -45)
        setShaderFloat('AbotSpeakerDarkVisualizer'..bar, 'contrast', 0)
        setShaderFloat('AbotSpeakerDarkVisualizer'..bar, 'brightness', -12)
    end

    makeLuaSprite('AbotEyesDark')
    makeGraphic('AbotEyesDark', 140, 60, '6F96CE')
    if characterType ~= '' then
        setObjectOrder('AbotEyesDark', getObjectOrder(characterType..'Group'))
    end
    addLuaSprite('AbotEyesDark')

    makeFlxAnimateSprite('AbotPupilsDark')
    loadAnimateAtlas('AbotPupilsDark', 'abot/systemEyes')
    if characterType ~= '' then
        setObjectOrder('AbotPupilsDark', getObjectOrder(characterType..'Group'))
    end
    addLuaSprite('AbotPupilsDark')

    looksAtPlayer = getPropertyFromClass('states.PlayState', 'SONG.notes['..curSection..'].mustHitSection')
    if looksAtPlayer == false then
        setProperty('AbotPupilsDark.anim.curFrame', 17)
        pauseAnim('AbotPupilsDark')
    else
        setProperty('AbotPupilsDark.anim.curFrame', 0)
        pauseAnim('AbotPupilsDark')
    end
    
    makeFlxAnimateSprite('AbotSpeakerDark')
    loadAnimateAtlas('AbotSpeakerDark', 'abot/dark/abotSystem')
    if characterType ~= '' then
        setObjectOrder('AbotSpeakerDark', getObjectOrder(characterType..'Group'))
    end
    addLuaSprite('AbotSpeakerDark')

    for property = 1, 2 do
        if characterType ~= '' then
            propertyTracker[property][2] = getProperty(characterType..'.'..propertyTracker[property][1])
            setAbotSpeakerDarkProperty(propertyTracker[property][1], propertyTracker[property][2])
        else
            propertyTracker[property][2] = getProperty('AbotSpeakerDark.'..propertyTracker[property][1])
            setProperty('AbotSpeakerDark.'..propertyTracker[property][1], offsetData[property])
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
        game.variables.get('AbotSpeakerDark').destroy();
        game.variables.remove('AbotSpeakerDark');
        game.variables.get('AbotPupilsDark').destroy();
        game.variables.remove('AbotPupilsDark');
    ]])
    removeLuaSprite('AbotSpeakerDarkBG')
    for bar = 1, 7 do
        removeLuaSprite('AbotSpeakerDarkVisualizer'..bar)
    end
    removeLuaSprite('AbotEyesDark')
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
        playAnim('AbotSpeakerDark', '', true, false, 1)
        for bar = 1, 7 do
            playAnim('AbotSpeakerDarkVisualizer'..bar, 'idle', true)
        end
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
        playAnim('AbotSpeakerDark', '', true, false, 1)
        for bar = 1, 7 do
            playAnim('AbotSpeakerDarkVisualizer'..bar, 'idle', true)
        end
    end
end

function onMoveCamera(character)
    -- Abot will look to the right (towards the player).
    if character == 'boyfriend' then
        if looksAtPlayer == false then
            playAnim('AbotPupilsDark', '', true, false, 17)
        end
    end
    -- Abot will look to the left (towards the opponent).
    if character == 'dad' then
        if looksAtPlayer == true then
            playAnim('AbotPupilsDark', '', true, false, 0)
        end
    end
end

function onUpdatePost(elapsed)
    for property = 1, #propertyTracker do
        if propertyTracker[property][2] ~= getProperty(characterType..'.'..propertyTracker[property][1]) then
            propertyTracker[property][2] = getProperty(characterType..'.'..propertyTracker[property][1])
            setAbotSpeakerDarkProperty(propertyTracker[property][1], propertyTracker[property][2])
        end
    end
    
    --[[
        These make it so the animations stop when they're supposed to be,
        instead of looping endlessly.
    ]] 
    if getProperty('AbotSpeakerDark.anim.curFrame') >= 15 then
        pauseAnim('AbotSpeakerDark')
    end
    if looksAtPlayer == true then
        if getProperty('AbotPupilsDark.anim.curFrame') >= 17 then
            looksAtPlayer = false
            pauseAnim('AbotPupilsDark')
        end
    end
    if looksAtPlayer == false then
        if getProperty('AbotPupilsDark.anim.curFrame') >= 31 then
            looksAtPlayer = true
            pauseAnim('AbotPupilsDark')
        end
    end
    -- This is how we control the animations' speed depending on the 'playbackRate' for Atlas Sprites.
    setProperty('AbotSpeakerDark.anim.framerate', 24 * playbackRate)
    setProperty('AbotPupilsDark.anim.framerate', 24 * playbackRate)
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
    setProperty('AbotSpeakerDark.alpha', 0.5)   --> If not attached to any character type.

    'doTween' functions also work the same way. 
]]
function setAbotSpeakerDarkProperty(property, value)
    if property == 'x' then
        if characterType ~= '' then
            value = value + offsetData[1]
            setProperty('AbotSpeakerDark.'..property, value - 100)
        end
        for bar = 1, 7 do
            setProperty('AbotSpeakerDarkVisualizer'..bar..'.'..property, getProperty('AbotSpeakerDark.'..property) + 200 + visualizerOffsetX(bar))
        end
        setProperty('AbotSpeakerDarkBG.'..property, getProperty('AbotSpeakerDark.'..property) + 165)
        setProperty('AbotEyesDark.'..property, getProperty('AbotSpeakerDark.'..property) + 30)
        setProperty('AbotPupilsDark.'..property, getProperty('AbotSpeakerDark.'..property) - 507)
    elseif property == 'y' then
        if characterType ~= '' then
            value = value + offsetData[2]
            setProperty('AbotSpeakerDark.'..property, value + 316)
        end
        for bar = 1, 7 do
            setProperty('AbotSpeakerDarkVisualizer'..bar..'.'..property, getProperty('AbotSpeakerDark.'..property) + 84 + visualizerOffsetY(bar))
        end
        setProperty('AbotSpeakerDarkBG.'..property, getProperty('AbotSpeakerDark.'..property) + 30)
        setProperty('AbotEyesDark.'..property, getProperty('AbotSpeakerDark.'..property) + 230)
        setProperty('AbotPupilsDark.'..property, getProperty('AbotSpeakerDark.'..property) - 492)
    else
        if characterType ~= '' then
            setProperty('AbotSpeakerDark.'..property, value)
        end
        for bar = 1, 7 do
            setProperty('AbotSpeakerDarkVisualizer'..bar..'.'..property, value)
        end
        setProperty('AbotSpeakerDarkBG.'..property, value)
        setProperty('AbotEyesDark.'..property, value)
        setProperty('AbotPupilsDark.'..property, value)
    end
end

--[[ Old version of the function above.
function updateSpeaker(property)
    if property == 'x' then
        setProperty('AbotSpeakerDark.'..property, offset.x - 100)
        for bar = 1, 7 do
            setProperty('AbotSpeakerDarkVisualizer'..bar..'.'..property, offset.x + 100 + visualizerOffsetX(bar))
        end
        setProperty('AbotSpeakerDarkBG.'..property, offset.x + 65)
        setProperty('AbotEyesDark.'..property, offset.x - 60)
        setProperty('AbotPupilsDark.'..property, offset.x - 607)
    elseif property == 'y' then
        setProperty('AbotSpeakerDark.'..property, offset.y + 316)
        for bar = 1, 7 do
            setProperty('AbotSpeakerDarkVisualizer'..bar..'.'..property, offset.y + 400 + visualizerOffsetY(bar))
        end
        setProperty('AbotSpeakerDarkBG.'..property, offset.y + 347)
        setProperty('AbotEyesDark.'..property, offset.y + 567)
        setProperty('AbotPupilsDark.'..property, offset.y - 176)
    elseif characterType ~= '' then
        setProperty('AbotSpeakerDark.'..property, getProperty(characterType..'.'..property))
        for bar = 1, 7 do
            setProperty('AbotSpeakerDarkVisualizer'..bar..'.'..property, getProperty(characterType..'.'..property))
        end
        setProperty('AbotSpeakerDarkBG.'..property, getProperty(characterType..'.'..property))
        setProperty('AbotEyesDark.'..property, getProperty(characterType..'.'..property))
        setProperty('AbotPupilsDark.'..property, getProperty(characterType..'.'..property))
    end
end
]]

--[[
    This handles the offsets for each visualizer bar.
    Again, it is to make things automatic instead of doing everything manually.
]]
local visualizerPosX = {0, 59, 56, 66, 54, 52, 51}
local visualizerPosY = {0, -8, -3.5, -0.4, 0.5, 4.7, 7}
function visualizerOffsetX(bar)
    local i = 1
    local offsetX = 0
    while i <= bar do
        offsetX = offsetX + visualizerPosX[i]
        i = i + 1
    end
    return offsetX
end

function visualizerOffsetY(bar)
    local i = 1
    local offsetY = 0
    while i <= bar do
        offsetY = offsetY + visualizerPosY[i]
        i = i + 1
    end
    return offsetY
end

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