
local JoyRocker = class("JoyRocker", function()
	
	return display.newLayer("JoyRocker")
end)

-- rocker and its background, rocker move in rocker_bg
local _rocker = nil
local _rocker_bg = nil

-- the sppedUp button
local _a = nil
local speedUp = false

-- snake's direction, get from JoyRocker
local snakeDir = cc.p(1,0)
cc.pNormalize(snakeDir)

-- deal with the speedUp button
local function touchEvent(obj, type)
	if type == ccui.TouchEventType.began then
		if obj == _a then
			speedUp = true
		end
	elseif type == ccui.TouchEventType.ended then
		if obj == _a then
			speedUp = false
		end
	-- when button cancelled
	elseif type == 3 then
		if obj == _a then
			speedUp = false
		end
	end
end

function JoyRocker:ctor()

	local size = display.size

	-- pos of the rocker's center
	local  _rockerX = 200
	local  _rockerY = _rockerX

	-- add rocker and its bg, speed up button
	_rocker_bg = ccui.Button:create():addTo(self)
	_rocker = ccui.Button:create():addTo(self)
	_a = ccui.Button:create("rock.png"):addTo(self)

	-- put button at right of the screen
	local rockerDot = display.newDrawNode():center():setPosition(cc.p(0,0)):addTo(_rocker)
	rockerDot:drawDot(cc.p(0,0), 35, cc.c4f(0.4,0.4,0.4,0.7))

	local rockerBgDot = display.newDrawNode():center():setPosition(cc.p(0,0)):addTo(_rocker_bg)
	rockerBgDot:drawDot(cc.p(0,0), 80, cc.c4f(0.4,0.4,0.4,0.4))

	local _aDot = display.newDrawNode():center():setPosition(cc.p(0,0)):addTo(_a)
	_aDot:drawDot(cc.p(38,38), 50, cc.c4f(0.4,0.4,0.4,1))

	_a:setPosition(cc.p(size.width-_a:getContentSize().width-150,200))
	_a:addTouchEventListener(touchEvent)

	_rocker_bg:setPosition(cc.p(_rockerX,_rockerY))
	_rocker_bg:setTouchEnabled(false)

	-- set anchor point to center will be easy to calculate the direciton
	_rocker:setAnchorPoint(cc.p(0.5,0.5))
	_rocker:setPosition(cc.p(_rockerX,_rockerY))
	_rocker:setTouchEnabled(false)

	-- add touch event, update the direction when touch began and moved
	local event = cc.Director:getInstance():getEventDispatcher()
	local rockerDangeEvent = cc.EventListenerTouchOneByOne:create()

	rockerDangeEvent:registerScriptHandler(function(touch,e)
		-- call the func touchControl() to calculate and update direction
		return touchControl(touch,_rockerX,_rockerY)
	end,cc.Handler.EVENT_TOUCH_BEGAN)

	rockerDangeEvent:registerScriptHandler(function(touch,e)
		return touchControl(touch,_rockerX,_rockerY)
	end,cc.Handler.EVENT_TOUCH_MOVED)

	rockerDangeEvent:registerScriptHandler(function(touch,e)
		_rocker:setPosition(cc.p(_rockerX,_rockerY))
	end,cc.Handler.EVENT_TOUCH_ENDED)

	rockerDangeEvent:registerScriptHandler(function(touch,e)
		_rocker:setPosition(cc.p(_rockerX,_rockerY))
	end,cc.Handler.EVENT_TOUCH_CANCELLED)

	event:addEventListenerWithSceneGraphPriority(rockerDangeEvent, _rocker_bg)

end

-- get touch point, and calculate the direction from center of rocker
function touchControl(touch,_rockerX,_rockerY)

	local point = touch:getLocation()
	-- when touch point not too far from rocker, in 550
	if cc.pGetDistance(cc.p(_rockerX,_rockerY),point) < 400 then
		snakeDir = cc.p(point.x - _rockerX, point.y - _rockerY)
		snakeDir = cc.pNormalize(snakeDir)

		-- when touch point out of its bg, let it leave in the bg
		if 45 < cc.pGetDistance(cc.p(_rockerX,_rockerY),point) then
			_rocker:setPosition(cc.p(snakeDir.x*45+_rockerX,snakeDir.y*45+_rockerY))
		else
			-- or let rocker at the touch point
			_rocker:setPosition(cc.p(point.x,point.y))
		end
		return true
	end

	return false
end

function JoyRocker:getSnakeDir()
	return snakeDir
end

function JoyRocker:getSpeedUp()
	return speedUp
end

return JoyRocker