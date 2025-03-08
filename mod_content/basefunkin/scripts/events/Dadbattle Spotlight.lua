--[[Recreation by Gostar64 [Probably doesn't work on android]
	Works on Psych Engine 0.7.3 [And maybe some older versions]
	Don't remove this credit thing or I'll be sad Ex: [:(]

	Also this is based off of Super_Hugo's Philly Glow Recreation
]]

--image folder

folder = "stagespotlight/"

-- smoke pos
smokeX = -1550
smokeY = 660

--smoke offset
offsetX = 200

--Spotlight Base Position
spotlightX = 400
spotlightY = -400

-- Spotlight offset
lightOffsetXDad = 0;
lightOffsetYDad = 100;

lightOffsetXBF = 0;
lightOffsetYBF = -50;

lightOffsetXGF = 0;
lightOffsetYGF = 10;

local color = ''; --set this for stages

-- Variables that you dont touch

local who = 'gf';
local val = 0;


--dont touch (grabs defaultCamZoom)
local defaultedCameraZoom = 0.0;


function onCreate()
	--offsets, set it here
	local curStage = getPropertyFromClass('states.PlayState', 'curStage')
	
	if curStage == 'customstagehere' then
		--cool example
		lightOffsetXBF = 240
		color = 'FFFF00'
	end

	if curStage == 'mallEvil' then
		color = 'E62145'

		smokeX = -800
		smokeY = 650
		spotlightX = 0
		spotlightY = 0

		lightOffsetXDad = 50
	end

	--yeah, using SuperHugo's Philly Glow Recreation as a base
	makeLuaSprite('dadbattleBlack')
	makeGraphic('dadbattleBlack', screenWidth, screenHeight, '000000')
	setProperty('dadbattleBlack.visible', false)
	setProperty('dadbattleBlack.alpha', 0.25)
	setObjectCamera('dadbattleBlack', 'hud')
	addLuaSprite('dadbattleBlack', true)


	--[[ if color ~= nil and color ~= '' then
		if not stringStartsWith(color, '0xFF') then
			color = '0xFF'..color;
		else
			color = color;
		end
	else
		color = '0xFFFFFFFF';
	end ]]
	if color == '' then
		color = 'FFFFFF'
	end
	
	makeLuaSprite('dadbattleLightEvent', folder.."spotlight", spotlightX, spotlightY)
	setProperty('dadbattleLightEvent.alpha', 0.375)
	setBlendMode('dadbattleLightEvent', 'add')
	setProperty('dadbattleLightEvent.visible', false)
	setProperty('dadbattleLightEvent.color', getColorFromHex(color))
	addLuaSprite('dadbattleLightEvent', true)
	updateHitbox('dadbattleLightEvent')

	makeLuaSprite('smoke1', folder..'smoke',  smokeX + offsetX, smokeY + getRandomFloat(-20, 20))
	setGraphicSize('smoke1', getProperty('smoke1.width')*getRandomFloat(1.1, 1.22), getProperty('smoke1.height')*1, false)
	updateHitbox('smoke1')
	setProperty('smoke1.alpha', 0.7)
	setBlendMode('smoke1', 'add')
	addLuaSprite('smoke1', true)

	setProperty('smoke1.visible', false)

	makeLuaSprite('smoke2', folder..'smoke', -smokeX + offsetX, smokeY + getRandomFloat(-20, 20))
	setGraphicSize('smoke2', getProperty('smoke2.width')*getRandomFloat(1.1, 1.22), getProperty('smoke2.height')*1, false)
	updateHitbox('smoke2')
	setProperty('smoke2.alpha', 0.7)
	setProperty('smoke2.flipX', true)
	setBlendMode('smoke2', 'add')
	addLuaSprite('smoke2', true)

	setProperty('smoke2.visible', false)
	
	defaultedCameraZoom = getProperty('defaultCamZoom') --this is important kind of
end

function onEvent(n, v1, value2)
	if n == 'Dadbattle Spotlight' then

		local lightOffsetX = 0;
		local lightOffsetY = 0;
	

		local val = 0;

		val = tonumber(v1);

		if val == 0 then --disable
			setProperty('dadbattleBlack.visible', false)
			setProperty('dadbattleLightEvent.visible', false)
			setProperty('defaultCamZoom', defaultedCameraZoom)

			doTweenAlpha('smokeLeaves', 'smoke1', 0, 1, 'linear')
			doTweenAlpha('smokeAlsoLeaves', 'smoke2', 0, 1, 'linear')

			setProperty('smoke1.velocity.x', 0)

			setProperty('smoke2.velocity.x', 0)

			setPositionThing('smoke1', smokeX + offsetX, smokeY)
			setPositionThing('smoke2', -smokeX + offsetX, smokeY)
		end

		if val == 1 then --enable time real
			setProperty('dadbattleBlack.visible', true)
			setProperty('dadbattleLightEvent.visible', true)

			setProperty('smoke1.velocity.x', getRandomFloat(15, 22))

			setProperty('smoke2.velocity.x', getRandomFloat(-15, -22))

			for i = 1, 2 do 
				setProperty('smoke'..i..'.visible', true)
			end

			setProperty('defaultCamZoom', defaultedCameraZoom + 0.12)
		end

		if val == 2 then
			who = 'dad'

			lightOffsetX = lightOffsetXDad;
			lightOffsetY = lightOffsetYDad;
		elseif val == 3 then
			who = 'boyfriend'

			lightOffsetX = lightOffsetXBF;
			lightOffsetY = lightOffsetYBF;
		elseif val == 4 then
			who = 'gf'	--now that's something that wasn't in the original

			lightOffsetX = lightOffsetXGF;
			lightOffsetY = lightOffsetYGF;
		end

		if val > 0 then
			setProperty('dadbattleLightEvent.alpha', 0)
			if val > 1 then
				runTimer('dadbattleSpotlightTimer', 0.12)
			end
			setPositionThing('dadbattleLightEvent', (getGraphicMidpointX(who) - getProperty('dadbattleLightEvent.width') / 2) + lightOffsetX, (getProperty(who..'.y') + getProperty(who..'.height') - getProperty('dadbattleLightEvent.height')) + lightOffsetY)
		end
	end
end

function onTimerCompleted(tag, loops, loopsLeft)
	if tag == 'dadbattleSpotlightTimer' then
		setProperty('dadbattleLightEvent.alpha', 0.375)
	end

end

function onTweenCompleted(tag)
	if tag == 'smokeLeaves' then
		setProperty('smoke1.visible', false)
		setProperty('smoke1.alpha', 0.7)
	elseif tag == 'smokeAlsoLeaves' then
		setProperty('smoke2.visible', false)
		setProperty('smoke2.alpha', 0.7)
	end
end

function setPositionThing(tag, x, y)
	if tag ~= nil then
		if x ~= nil then
			setProperty(tag..'.x', x);
		end
		if y ~= nil then
			setProperty(tag..'.y', y);
		end
	end
end

function getBfColor()
	local colorR = getProperty("boyfriend.healthColorArray")[1]
	local colorG = getProperty("boyfriend.healthColorArray")[2]
	local colorB = getProperty("boyfriend.healthColorArray")[3]
	return DEC_HEX(colorR) .. DEC_HEX(colorG) .. DEC_HEX(colorB)
end
 
function getGfColor()
	local colorR = getProperty("gf.healthColorArray")[1]
	local colorG = getProperty("gf.healthColorArray")[2]
	local colorB = getProperty("gf.healthColorArray")[3]
	return DEC_HEX(colorR) .. DEC_HEX(colorG) .. DEC_HEX(colorB)
end
 
function getDadColor()
	local colorR = getProperty("dad.healthColorArray")[1]
	local colorG = getProperty("dad.healthColorArray")[2]
	local colorB = getProperty("dad.healthColorArray")[3]
	return DEC_HEX(colorR) .. DEC_HEX(colorG) .. DEC_HEX(colorB)
end

function DEC_HEX(IN)
    local B,K,OUT,I,D,addZero=16,"0123456789ABCDEF","",0,false
    if IN == 0 then
        return "00"
    elseif IN <= 15 and IN ~= 0 then
        addZero = true
    end
    while IN>0 do
        I=I+1
        IN,D=math.floor(IN/B),math.mod(IN,B)+1
        OUT=string.sub(K,D,D)..OUT
    end
    if addZero then
        OUT = "0"..OUT
    end
    return OUT
end