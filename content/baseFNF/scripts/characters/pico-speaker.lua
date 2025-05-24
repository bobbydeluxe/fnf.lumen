function onCreatePost()
    addLuaScript('scripts/props/speaker')
    callScript('scripts/props/speaker', 'createSpeaker', {'pico-speaker', -190, 438}) -- {characterName, offsetX, offsetY}
end