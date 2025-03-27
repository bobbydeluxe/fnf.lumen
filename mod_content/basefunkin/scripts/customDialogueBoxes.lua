-- script by skellix

local ffi = require("ffi")  -- Load FFI module (instance)

local user32 = ffi.load("user32")   -- Load User32 DLL handle

ffi.cdef([[
enum{
    MB_OK = 0x00000000L,
    MB_ICONINFORMATION = 0x00000040L
};

typedef void* HANDLE;
typedef HANDLE HWND;
typedef const char* LPCSTR;
typedef unsigned UINT;

int MessageBoxA(HWND, LPCSTR, LPCSTR, UINT);
]]) -- Define C -> Lua interpretation

--deactivate these vars and this function for use without autodetect - bdx

local langCode = getPropertyFromClass('backend.ClientPrefs', 'data.language')
local langCodeFinal

inCutscene = true
function onStartCountdown()
    if langCode == 'en-US' then
        langCodeFinal = ""
    else
        langCodeFinal = "-"..langCode
    end
end

--dont mess with shit d'low unless u know what u doin - bdx

function onTimerCompleted(t)
    if t == 'startDialogue' then
        if checkFileExists('data/songs/'..string.lower(string.gsub(songName, "%s+", "-"))..'/dialogue'..langCodeFinal..'.json') then
            openCustomSubstate('custom_dialogue', true)
        else
            exitCustomDialogue()
        end
    end

    if t == 'scroll' then
        setTextString('dialogueText', string.sub(string, 1, scrolled))
        scrolled = scrolled + 1
        
        if dialogueJSON.dialogue[page].sound[2] == nil then
            if (dialogueJSON.dialogue[page].sound == nil or dialogueJSON.dialogue[page].sound == '') or checkFileExists('sounds/'..dialogueJSON.dialogue[page].sound..'.ogg') == false then
                playSound('scrollMenu')
            else
                playSound(dialogueJSON.dialogue[page].sound)
            end
        else
            local randomSound = math.random(1,#dialogueJSON.dialogue[page].sound)
            if checkFileExists('sounds/'..dialogueJSON.dialogue[page].sound[randomSound]..'.ogg') == true then
                 playSound(dialogueJSON.dialogue[page].sound[randomSound])
            else
                playSound('scrollMenu')
            end
        end

        if getProperty('dialogueText.text') ~= string then
            pagePrinted = false
            runTimer('scroll', scrollSpeed)
        else
            pagePrinted = true
            playAnim('portrait', dialogueJSON.dialogue[page].expression)
        end
    end
end

function onCustomSubstateCreate()

    page = 1
    -- Check for dependencies and give error messages before closing dialogue if they aren't found.
    dialogueJSON = callMethodFromClass('tjson.TJSON', 'parse', {getTextFromFile('data/songs/'..string.lower(string.gsub(songName, "%s+", "-"))..'/dialogue'..langCodeFinal..'.json')})

    if dialogueJSON.dialogue[page].use_box == nil then
        user32.MessageBoxA(nil, 'use_box returned nil in "data/songs/'..string.lower(string.gsub(songName, "%s+", "-"))..'/dialogue'..langCodeFinal..'.json".', 'Error: Dialogue JSON Error', ffi.C.MB_OK + ffi.C.MB_ICONINFORMATION)
        exitCustomDialogue()
        return
    end

    if checkFileExists('dialogueBoxes/'..dialogueJSON.dialogue[page].use_box..'.json') then
        boxJSON = callMethodFromClass('tjson.TJSON', 'parse', {getTextFromFile('dialogueBoxes/'..dialogueJSON.dialogue[page].use_box..'.json')})
    else
        user32.MessageBoxA(nil, 'Could not find "dialogueBoxes/'..dialogueJSON.dialogue[page].use_box..'.json".', 'Error: Missing File', ffi.C.MB_OK + ffi.C.MB_ICONINFORMATION)
        exitCustomDialogue()
        return
    end
    
    if checkFileExists('images/dialogue/'..dialogueJSON.dialogue[1].portrait..'.json') then
        portraitJSON = callMethodFromClass('tjson.TJSON', 'parse', {getTextFromFile('images/dialogue/'..dialogueJSON.dialogue[1].portrait..'.json')})
    else
        user32.MessageBoxA(nil, 'Could not find "images/dialogue/'..dialogueJSON.dialogue[1].portrait..'.json".', 'Error: Missing File', ffi.C.MB_OK + ffi.C.MB_ICONINFORMATION)
        exitCustomDialogue()
        return
    end

    -- create dialogue portraits
    makeAnimatedLuaSprite('portrait', 'dialogue/'..portraitJSON.image, portraitJSON.position[1], portraitJSON.position[2])
    resetPortrait()

    -- create box
    resetDialogueBox(false)

    -- handle nametags(if enabled)
    resetNameTags()

    resetDialogueString(dialogueJSON.dialogue[1].text, 'scrollMenu', dialogueJSON.dialogue[1].speed, false)
end

function onCustomSubstateUpdate()
    if (isBoxAnimFinished('appear') == true) then
        playAnim('box', 'idle'..boxJSON.states[boxCurState.index].prefix)
    end

    if keyJustPressed('back') then
        fadeDialogueShit()
    end

    if page > #dialogueJSON.dialogue then
        fadeDialogueShit()
    else
        if keyJustPressed('accept') or keyJustPressed('ui_right') then
            if pagePrinted == false then
                cancelTimer('scroll')
                setTextString('dialogueText', string)
                pagePrinted = true
                playAnim('portrait', dialogueJSON.dialogue[page].expression)
            else
                page = page + 1
                resetDialogueString(dialogueJSON.dialogue[page].text, 'scrollMenu', dialogueJSON.dialogue[page].speed, false)
            end
        end
    end
    
    if page < 1 then
        page = 1
    else
        if keyJustPressed('ui_left') then
            if pagePrinted == false then
                cancelTimer('scroll')
                setTextString('dialogueText', string)
                pagePrinted = true
                playAnim('portrait', dialogueJSON.dialogue[page].expression)
            else
                page = page - 1
                resetDialogueString(dialogueJSON.dialogue[page].text, 'scrollMenu', dialogueJSON.dialogue[page].speed, true)
            end
        end
    end

    if getProperty('box.alpha') < 0.5 then
        exitCustomDialogue()
    end

    setProperty('dialogueText.x', getProperty('box.x') + boxJSON.textOrigin[1])
    setProperty('dialogueText.y', getProperty('box.y') + boxJSON.textOrigin[2])
end

function resetPortrait()
    portraitJSON = callMethodFromClass('tjson.TJSON', 'parse', {getTextFromFile('images/dialogue/'..dialogueJSON.dialogue[page].portrait..'.json')})
    makeAnimatedLuaSprite('portrait', 'dialogue/'..portraitJSON.image, portraitJSON.position[1], portraitJSON.position[2] + 50)
    for i = 1, #portraitJSON.animations do
        addAnimationByPrefix('portrait', portraitJSON.animations[i].anim, portraitJSON.animations[i].idle_name, 24, false)
        addOffset('portrait', portraitJSON.animations[i].anim, portraitJSON.animations[i].idle_offsets[1], portraitJSON.animations[i].idle_offsets[2])
        addAnimationByPrefix('portrait', portraitJSON.animations[i].anim..'-loop', portraitJSON.animations[i].loop_name, 24, true)
        addOffset('portrait', portraitJSON.animations[i].anim..'-loop', portraitJSON.animations[i].loop_offsets[1], portraitJSON.animations[i].loop_offsets[2])
    end
    setProperty('portrait.scale.x', (portraitJSON.scale * 0.75))
    setProperty('portrait.scale.y', (portraitJSON.scale * 0.75))
    playAnim('portrait', dialogueJSON.dialogue[page].expression..'-loop')
    if portraitJSON.dialogue_pos == 'right' then
        setProperty('portrait.x', 800 - getProperty('portrait.x'))
    elseif portraitJSON.dialogue_pos == 'center' then
        setProperty('portrait.x', 500 - getProperty('portrait.x'))
    end
    setObjectCamera('portrait', 'camHUD')
    insertToCustomSubstate('portrait', 1)
    addLuaSprite('portrait', true)
end

function resetDialogueBox(back)
    if checkFileExists('dialogueBoxes/'..dialogueJSON.dialogue[page].use_box..'.json') then
        boxJSON = callMethodFromClass('tjson.TJSON', 'parse', {getTextFromFile('dialogueBoxes/'..dialogueJSON.dialogue[page].use_box..'.json')})
    else
        user32.MessageBoxA(nil, 'Could not find "dialogueBoxes/'..dialogueJSON.dialogue[page].use_box..'.json".', 'Error: Missing File', ffi.C.MB_OK + ffi.C.MB_ICONINFORMATION)
        exitCustomDialogue()
        return
    end
    
    makeAnimatedLuaSprite('box', boxJSON.image, boxJSON.boxPosition[1], boxJSON.boxPosition[2])
    boxCurState = {name = dialogueJSON.dialogue[1].boxState, index = 0}
    setObjectCamera('box', 'camHUD')
    setProperty('box.antialiasing', boxJSON.antialiasing)
    setProperty('box.scale.x', boxJSON.scale)
    setProperty('box.scale.y', boxJSON.scale)

    boxCurState = {name = dialogueJSON.dialogue[page].boxState, index = 0}
    local foundState = false
    for i = 1, #boxJSON.states do
        if boxJSON.states[i].name == boxCurState.name then
            boxCurState.index = i
            foundState = true
        elseif i == #boxJSON.states and foundState == false then
            user32.MessageBoxA(nil, 'invalid box state.', 'Error: Dialogue JSON Error', ffi.C.MB_OK + ffi.C.MB_ICONINFORMATION)
            exitCustomDialogue()
            return
        end
    end
    
    for i = 1, #boxJSON.animations do
        if boxJSON.animations[i].indices ~= nil then
            addAnimationByIndices('box', boxJSON.animations[i].name, boxJSON.animations[i].prefix, boxJSON.animations[i].indices, boxJSON.animations[i].fps, boxJSON.animations[i].loop)
        else
            addAnimationByPrefix('box', boxJSON.animations[i].name, boxJSON.animations[i].prefix, boxJSON.animations[i].fps, boxJSON.animations[i].loop)
        end
        addOffset('box', boxJSON.animations[i].name, boxJSON.animations[i].offsets[1], boxJSON.animations[i].offsets[2])
    end

    if back == false then
        playAnim('box', 'appear'..boxJSON.states[boxCurState.index].prefix, true)
    else
        playAnim('box', 'idle'..boxJSON.states[boxCurState.index].prefix)
    end
    insertToCustomSubstate('box', 2)
    addLuaSprite('box', true)

    if (isBoxAnimFinished('appear') == true) or page ~= 1 then
        playAnim('box', 'idle'..boxJSON.states[boxCurState.index].prefix)
    end
end

function resetNameTags()
    if boxJSON.nametags ~= nil then
        if boxJSON.nametags == true and dialogueJSON.dialogue[page].nameTag_text ~= nil then
            makeLuaText('nametag', dialogueJSON.dialogue[page].nameTag_text, 0, getProperty('box.x') + boxJSON.nametagsPosition[1], getProperty('box.y') + boxJSON.nametagsPosition[2])
            insertToCustomSubstate('nametag', 999)
            setTextSize('nametag', 60)
            setObjectCamera('nametag', 'other')
            addLuaText('nametag', true)
        end
    end
end

function resetDialogueString(str,snd,spd,wentBack)
    lastBoxUsed = dialogueJSON.dialogue[page].use_box
    resetDialogueBox(wentBack)
    setTextString('dialogueText', '')
    setTextString('nametag', string.upper(string.sub(dialogueJSON.dialogue[page].portrait, 1, 1))..string.sub(dialogueJSON.dialogue[page].portrait, 2, string.len(dialogueJSON.dialogue[page].portrait)))

    string = str
    scrollSound = snd
    scrolled = 1
    if spd == nil then scrollSpeed = 0.05 else scrollSpeed = spd end
    if boxJSON.lineWidth == nil then
        user32.MessageBoxA(nil, 'lineWidth returned nil in "dialogueBoxes/'..dialogueJSON.dialogue[page].use_box..'.json".', 'Error: Dialogue Box JSON Error', ffi.C.MB_OK + ffi.C.MB_ICONINFORMATION)
        exitCustomDialogue()
        return
    else
        makeLuaText('dialogueText', '', boxJSON.lineWidth, boxJSON.boxPosition[1] + boxJSON.textOrigin[1], boxJSON.boxPosition[2] + boxJSON.textOrigin[2])
    end
    setTextAlignment('dialogueText', 'left')
    insertToCustomSubstate('dialogueText')
    setObjectCamera('dialogueText', 'other')
    addLuaText('dialogueText', true)
    
    setTextSize('dialogueText', 30)

    if checkFileExists('images/dialogue/'..dialogueJSON.dialogue[page].portrait..'.json') then
        resetPortrait()
    end
    resetNameTags()

    runTimer('scroll', scrollSpeed)
end

function exitCustomDialogue()
    doTweenAlpha('dialogueText_fadeOut', 'dialogueText', 0, 0.001)
    doTweenAlpha('box_fadeOut', 'box', 0, 0.001)
    doTweenAlpha('nametag_fadeOut', 'nametag', 0, 0.001)
    doTweenAlpha('portrait_fadeOut', 'portrait', 0, 0.001)
    setProperty('inCutscene', false);
    allowCountdown = true
    cancelTimer('scroll')
    closeCustomSubstate('custom_dialogue')
    startCountdown()
end

function fadeDialogueShit()
    local diaFadeTime = 0.15
    if boxJSON.destroyTime ~= nil then
        diaFadeTime = boxJSON.destroyTime
    end
    doTweenAlpha('dialogueText_fadeOut', 'dialogueText', 0, diaFadeTime)
    local foundAnim = false
    for i = 1, #boxJSON.animations do
        if boxJSON.animations[i].name == 'disappear'..boxJSON.states[boxCurState.index].prefix then
            playAnim('box', 'disappear'..boxJSON.states[boxCurState.index].prefix)
            foundAnim = true
        elseif i == #boxJSON.states and foundAnim == false then
            doTweenAlpha('box_fadeOut', 'box', 0, diaFadeTime)
        end
    end
    doTweenAlpha('nametag_fadeOut', 'nametag', 0, diaFadeTime)
    doTweenAlpha('portrait_fadeOut', 'portrait', 0, diaFadeTime)
end

function isBoxAnimFinished(animName)
    return getProperty('box.animation.name') == animName..boxJSON.states[boxCurState.index].prefix and getProperty('box.animation.finished') == true
end