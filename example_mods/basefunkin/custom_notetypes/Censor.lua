function onCreatePost()
    -- Split the imageFile path by commas and trim spaces
    local bfImages = split(getProperty('boyfriend.imageFile'), ', ')
    --debugPrint(bfImages[1])
    
    -- Only precache the first path (before any commas)
    precacheImage(bfImages[1] .. '_Censored')
end

local showCensorSprite = false
local noteDirection = {'left', 'down', 'up', 'right'}

function goodNoteHit(membersIndex, noteData, noteType, isSustainNote)
    if noteType == 'Censor' then
        setProperty('boyfriend.visible', false)
        makeCensorSprite(noteData)
        playAnim('censor', noteDirection[noteData + 1], true)
        showCensorSprite = true
    elseif showCensorSprite == true then
        setProperty('boyfriend.visible', true)
        setProperty('censor.visible', false)
        showCensorSprite = false
    end
end

function makeCensorSprite(noteData)
    if not luaSpriteExists('censor') then
        -- Split the imageFile path by commas and trim spaces
        local bfImages = split(getProperty('boyfriend.imageFile'), ', ')
        
        -- Create the censor sprite using the first imageFile in the list
        makeAnimatedLuaSprite('censor', bfImages[1] .. '_Censored', getProperty('boyfriend.x'), getProperty('boyfriend.y'))
        setObjectOrder('censor', getObjectOrder('boyfriendGroup'))
        addLuaSprite('censor', true)
    end

    -- Check if the animation for the current direction exists
    if not getProperty('censor.animOffsets.exists('..noteDirection[noteData + 1]..')') then
        addAnimationByPrefix('censor', noteDirection[noteData + 1], boyfriendName..' swear '..noteDirection[noteData + 1]..'0', 24, false)
        addOffset('censor', noteDirection[noteData + 1], getProperty('boyfriend.offset.x'), getProperty('boyfriend.offset.y'))
    end
    applyShader(curStage)
    setProperty('censor.visible', true)
end

-- Shader function remains the same
function applyShader(stage)
    setSpriteShader('censor', 'adjustColor')
    if stage == 'stageErect' then
        setShaderFloat('censor', 'hue', 12)
        setShaderFloat('censor', 'saturation', 0)
        setShaderFloat('censor', 'contrast', 7)
        setShaderFloat('censor', 'brightness', -23)
    elseif stage == 'phillyErect' then
        setShaderFloat('censor', 'hue', -26)
        setShaderFloat('censor', 'saturation', -16)
        setShaderFloat('censor', 'contrast', 0)
        setShaderFloat('censor', 'brightness', -5)
    elseif stage == 'limoErect' then
        setShaderFloat('censor', 'hue', -30)
        setShaderFloat('censor', 'saturation', -20)
        setShaderFloat('censor', 'contrast', 0)
        setShaderFloat('censor', 'brightness', -30)
    elseif stage == 'mallErect' or stage == 'mall' then
        setShaderFloat('censor', 'hue', 5)
        setShaderFloat('censor', 'saturation', 20)
        setShaderFloat('censor', 'contrast', 0)
        setShaderFloat('censor', 'brightness', 0)
    end
end

-- Helper function to split a string by a delimiter (comma + space)
function split(inputstr, delimiter)
    local t = {}
    for str in string.gmatch(inputstr, "([^" .. delimiter .. "]+)") do
        table.insert(t, str)
    end
    return t
end
