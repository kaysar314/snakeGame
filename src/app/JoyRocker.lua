-- by kaysar, 2016-9-27
local JoyRocker = class("JoyRocker", function()
	return display.newLayer("JoyRocker")
end)

-- the sppedUp button
local _a = nil
local speedUp = false

-- the center of rocker
local _rockerX = 200
local _rockerY = 200

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

	-- rocker and its background, rocker move in rocker_bg
	self._rocker = nil
	self._rocker_bg = nil

	self.size = display.size

	-- snake's direction, get from JoyRocker
	self.snakeDir = cc.p(1,0)

	-- pos of the rocker's center

	-- add rocker and its bg, speed up button
	self._rocker_bg = ccui.Button:create():addTo(self)
	self._rocker = ccui.Button:create():addTo(self)
	_a = ccui.Button:create("rock.png"):addTo(self)

	-- put button at right of the screen
	local rockerDot = display.newDrawNode():center():setPosition(cc.p(0,0)):addTo(self._rocker)
	rockerDot:drawDot(cc.p(0,0), 35, cc.c4f(0.4,0.4,0.4,0.7))

	local rockerBgDot = display.newDrawNode():center():setPosition(cc.p(0,0)):addTo(self._rocker_bg)
	rockerBgDot:drawDot(cc.p(0,0), 80, cc.c4f(0.4,0.4,0.4,0.4))

	local _aDot = display.newDrawNode():center():setPosition(cc.p(0,0)):addTo(_a)
	_aDot:drawDot(cc.p(38,38), 50, cc.c4f(0.4,0.4,0.4,1))

	_a:setPosition(cc.p(self.size.width-_a:getContentSize().width-150,200))
	_a:addTouchEventListener(touchEvent)

	self._rocker_bg:setPosition(cc.p(_rockerX,_rockerY))
	self._rocker_bg:setTouchEnabled(false)

	-- set anchor point to center will be easy to calculate the direciton
	self._rocker:setAnchorPoint(cc.p(0.5,0.5))
	self._rocker:setPosition(cc.p(_rockerX,_rockerY))
	self._rocker:setTouchEnabled(false)

	-- add touch event, update the direction when touch began and moved
	local event = cc.Director:getInstance():getEventDispatcher()
	local rockerDangeEvent = cc.EventListenerTouchOneByOne:create()

	rockerDangeEvent:registerScriptHandler(function(touch,e)
		-- call the func touchControl() to calculate and update direction
		return touchControl(touch,self)
	end,cc.Handler.EVENT_TOUCH_BEGAN)

	rockerDangeEvent:registerScriptHandler(function(touch,e)
		return touchControl(touch,self)
	end,cc.Handler.EVENT_TOUCH_MOVED)

	rockerDangeEvent:registerScriptHandler(function(touch,e)
		self._rocker:setPosition(cc.p(_rockerX,_rockerY))
	end,cc.Handler.EVENT_TOUCH_ENDED)

	rockerDangeEvent:registerScriptHandler(function(touch,e)
		self._rocker:setPosition(cc.p(_rockerX,_rockerY))
	end,cc.Handler.EVENT_TOUCH_CANCELLED)

	event:addEventListenerWithSceneGraphPriority(rockerDangeEvent, self._rocker_bg)

end

-- get touch point, and calculate the direction from center of rocker
function touchControl(touch,self)

	local point = touch:getLocation()
	-- when touch point not too far from rocker, in 550
	if cc.pGetDistance(cc.p(_rockerX,_rockerY),point) < 400 then
		self.snakeDir = cc.p(point.x - _rockerX, point.y - _rockerY)
		self.snakeDir = cc.pNormalize(self.snakeDir)

		-- when touch point out of its bg, let it leave in the bg
		if 45 < cc.pGetDistance(cc.p(_rockerX,_rockerY),point) then
			self._rocker:setPosition(cc.p(self.snakeDir.x*45+_rockerX,self.snakeDir.y*45+_rockerY))
		else
			-- or let rocker at the touch point
			self._rocker:setPosition(cc.p(point.x,point.y))
		end
		return true
	end

	return false
end

function JoyRocker:getSnakeDir(self)
	return self.snakeDir
end

function JoyRocker:getSpeedUp()
	return speedUp
end

return JoyRocker