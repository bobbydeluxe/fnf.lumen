function onCreate()
	makeLuaSprite('darkBG', 'mainStage/erect/backDark', 729, -170)
	addLuaSprite('darkBG')

	makeAnimatedLuaSprite('crowd', 'mainStage/erect/crowd', 560, 290)
	addAnimationByPrefix('crowd', 'idle', 'Symbol 2 instance 1', 12)
	setScrollFactor('crowd', 0.8, 0.8)
	addLuaSprite('crowd')

	if lowQuality == false then
		makeLuaSprite('smallLight', 'mainStage/erect/brightLightSmall', 967, -103)
		setScrollFactor('smallLight', 1.2, 1.2)
		setBlendMode('smallLight', 'ADD')
		addLuaSprite('smallLight')
	end

	makeLuaSprite('backStage', 'mainStage/erect/bg', -603, -187)
	addLuaSprite('backStage')

	if lowQuality == false then
		makeLuaSprite('server', 'mainStage/erect/server', -361, 205)
		addLuaSprite('server')

		makeLuaSprite('greenServerLight', 'mainStage/erect/lightgreen', -171, 242)
		setBlendMode('greenServerLight', 'ADD')
		addLuaSprite('greenServerLight')

		makeLuaSprite('redServerLight', 'mainStage/erect/lightred', -101, 560)
		setObjectOrder('redServerLight', getObjectOrder('greenServerLight'))
		setBlendMode('redServerLight', 'ADD')
		addLuaSprite('redServerLight')
	end

	makeLuaSprite('orangeHue', 'mainStage/erect/orangeLight', 189, -195)
	setBlendMode('orangeHue', 'ADD')
	addLuaSprite('orangeHue')

	if lowQuality == false then
		makeLuaSprite('stageLights', 'mainStage/erect/lights', -601, -147)
		setScrollFactor('stageLights', 1.2, 1.2)
		addLuaSprite('stageLights', true)

		makeLuaSprite('light', 'mainStage/erect/lightAbove', 804, -117)
		setBlendMode('light', 'ADD')
		addLuaSprite('light', true)
	end
end

function onCreatePost()
	if shadersEnabled == true then
		initLuaShader('adjustColor')
		setSpriteShader('boyfriend', 'adjustColor')
		setSpriteShader('dad', 'adjustColor')
		setSpriteShader('gf', 'adjustColor')

		setShaderFloat('boyfriend', 'hue', 12)
		setShaderFloat('boyfriend', 'saturation', 0)
		setShaderFloat('boyfriend', 'contrast', 7)
		setShaderFloat('boyfriend', 'brightness', -23)
		
		setShaderFloat('dad', 'hue', -32)
		setShaderFloat('dad', 'saturation', 0)
		setShaderFloat('dad', 'contrast', -23)
		setShaderFloat('dad', 'brightness', -33)

		setShaderFloat('gf', 'hue', -9)
		setShaderFloat('gf', 'saturation', 0)
		setShaderFloat('gf', 'contrast', -4)
		setShaderFloat('gf', 'brightness', -30)
	end

	-- Sets up the sprites for the 'Dadbattle Spotlight' event if it's present in the chart.
	for note = 0, getProperty('eventNotes.length') - 1 do
        if getPropertyFromGroup('eventNotes', note, 'event') == 'Dadbattle Spotlight' then
			makeLuaSprite('blackenScreen', '', -800, -400)
			makeGraphic('blackenScreen', screenWidth * 2, screenHeight * 2, '000000')
			setScrollFactor('blackenScreen', 0, 0)
			addLuaSprite('blackenScreen', true)
			setProperty('blackenScreen.alpha', 0.25)
			setProperty('blackenScreen.visible', false)
			
            makeLuaSprite('spotlight', 'mainStage/spotlight', 400, -400)
			setBlendMode('spotlight', 'ADD')
			addLuaSprite('spotlight', true)
			setProperty('spotlight.alpha', 0)
			setProperty('spotlight.visible', false)
			
			smoke1OffsetY = getRandomFloat(-15, 15)
			smoke1Scale = getRandomFloat(1.1, 1.22)
			smoke1Velocity = getRandomFloat(15, 22)
			makeLuaSprite('smoke1', 'mainStage/smoke', -1650, 680 + smoke1OffsetY)
			setGraphicSize('smoke1', getProperty('smoke1.width') * smoke1Scale)
			setScrollFactor('smoke1', 1.2, 1.05)
			addLuaSprite('smoke1', true)
			setProperty('smoke1.alpha', 0)
			setProperty('smoke1.velocity.x', smoke1Velocity)

			smoke2OffsetY = getRandomFloat(-15, 15)
			smoke2Scale = getRandomFloat(1.1, 1.22)
			smoke2Velocity = getRandomFloat(-22, -15)
			makeLuaSprite('smoke2', 'mainStage/smoke', 1850, 680 + smoke2OffsetY)
			setGraphicSize('smoke2', getProperty('smoke2.width') * smoke2Scale)
			setScrollFactor('smoke2', 1.2, 1.05)
			addLuaSprite('smoke2', true)
			setProperty('smoke2.alpha', 0)
			setProperty('smoke2.flipX', true)
			setProperty('smoke2.velocity.x', smoke2Velocity)
        end
    end
end

-- Everything from this point is for the 'Dadbattle Spotlight' event
function onEvent(eventName, value1, value2, strumTime)
	if eventName == 'Dadbattle Spotlight' then
		value = tonumber(value1)
		if value == nil then
			value = 0
		end
		
		if value > 0 then
			if value == 1 then -- Activates the event
				setProperty('defaultCamZoom', getProperty('defaultCamZoom') + 0.12)
				setProperty('smallLight.visible', false)
				setProperty('light.visible', false)
				setProperty('blackenScreen.visible', true)
				setProperty('spotlight.visible', true)
				setProperty('smoke1.visible', true)
				setProperty('smoke2.visible', true)
			end

			-- Sets up the spotlight's target
			local target = 'dad'
			if value > 2 then
				target = 'boyfriend'
			end
			runTimer('spotlightAppears', 0.12)
			setProperty('spotlight.x', getGraphicMidpointX(target) - getProperty('spotlight.width') / 2)
			setProperty('spotlight.y', getProperty(target..'.y') + getProperty(target..'.height') - getProperty('spotlight.height') + 50)
			doTweenAlpha('smoke1Appears', 'smoke1', 0.7, 1.5, 'quadInOut')
			doTweenAlpha('smoke2Appears', 'smoke2', 0.7, 1.5, 'quadInOut')
		else
			-- Deactivate the event
			setProperty('defaultCamZoom', getProperty('defaultCamZoom') - 0.12)
			setProperty('smallLight.visible', true)
			setProperty('light.visible', true)
			setProperty('blackenScreen.visible', false)
			setProperty('spotlight.visible', false)
			doTweenAlpha('smoke1ByeBye', 'smoke1', 0, 0.7, 'linear')
			doTweenAlpha('smoke2ByeBye', 'smoke2', 0, 0.7, 'linear')
		end
	end
end

function onTimerCompleted(tag, loops, loopsLeft)
	if tag == 'spotlightAppears' then
		setProperty('spotlight.alpha', 0.375)
	end
end