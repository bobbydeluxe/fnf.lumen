function onCreate()
    -- Needed variables and values to make the custom zoom behaviour work
    defaultCamZoom = getProperty('defaultCamZoom')
    camZoomingDecay = getProperty('camZoomingDecay')
    setProperty('camZoomingMult', 0)
    setProperty('camZoomingDecay', 0)
end

function onEvent(eventName, value1, value2, strumTime)
    if eventName == 'Set Camera Zoom' then
        cancelTween('camZoom')
        
        local zoomData = stringSplit(value1, ',')
        if zoomData[2] == 'stage' then
            -- The 'targetZoom' is the value multiplied by the 'defaultCamZoom'
            targetZoom = tonumber(zoomData[1]) * defaultCamZoom
        else
            -- The 'targetZoom' is just the value
            targetZoom = tonumber(zoomData[1])
        end
        
        if value2 == '' then
            -- Zooms instantly to the inputted value
            setProperty('defaultCamZoom', targetZoom)
        else
            -- Zooms to the inputted value by using a tween
            local tweenData = stringSplit(value2, ',')
            local duration = stepCrochet * tonumber(tweenData[1]) / 1000
            if tweenData[2] == nil then
                tweenData[2] = 'linear'
            end
            startTween('camZoom', 'this', {defaultCamZoom = targetZoom}, duration, {ease = tweenData[2]})
        end
    end

    -- Compability for this event with the custom zoom behaviour
    if eventName == 'Add Camera Zoom' then
        if cameraZoomOnBeat == true and getProperty('camGame.zoom') < 1.35 then
            zoomAdd = tonumber(value1)
            if zoomAdd == nil then
                zoomAdd = 0.015
            end
            zoomMultiplier = zoomMultiplier + zoomAdd
        end
    end
end

--[[
    Everything from down here is how this event handles the custom zoom behaviour.
    This was needed to make sure the camera doesn't spasm,
    when the zoom changes over time while bopping.
]]

zoomMultiplier = 1
-- Those 2 variables are used and changed by the 'Set Camera Bop' event
cameraZoomRate = 4
cameraZoomMult = 1
function onBeatHit()
    if cameraZoomRate > 0 and cameraZoomOnBeat == true then
        if getProperty('camGame.zoom') < 1.35 and curBeat % cameraZoomRate == 0 then
            zoomMultiplier = zoomMultiplier + 0.015 * cameraZoomMult
            setProperty('camHUD.zoom', getProperty('camHUD.zoom') + 0.03 * cameraZoomMult)
        end
    end
end

function onUpdatePost(elapsed)
    if getProperty('inCutscene') == false and getProperty('endingSong') == false then 
        if cameraZoomRate > 0 then
            zoomMultiplier = math.lerp(1, zoomMultiplier, math.exp(-elapsed * 3.125 * camZoomingDecay * playbackRate))
            setProperty('camGame.zoom', getProperty('defaultCamZoom') * zoomMultiplier)
            setProperty('camHUD.zoom', math.lerp(1, getProperty('camHUD.zoom'), math.exp(-elapsed * 3.125 * camZoomingDecay * playbackRate)))
        end
    end
end

function math.lerp(a, b, ratio)
    return a + ratio * (b - a)
end