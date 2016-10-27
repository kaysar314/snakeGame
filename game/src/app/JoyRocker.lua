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

function JoyRocker:ctor(head)

	-- rocker and its background, rocker move in rocker_bg
	self._rocker = nil
	self._rocker_bg = nil

	self.size = display.size

	self.first = head[1]
	self.headpos = {head[2],head[3]}

	-- snake's direction, get from JoyRocker
	self.snakeDir = cc.p(1,0)
	self.PosList = {first = 0, last = -1}

	for i = 1,15 do
		self.PosList.first = self.PosList.first - 1
		if self.PosList.last > self.PosList.first then
			self.PosList[self.PosList.first] = {self.first,self.PosList[self.PosList.first+1][2]+self.snakeDir.x*3,self.PosList[self.PosList.first+1][3]+self.snakeDir.y*3,false}
		else
    		self.PosList[self.PosList.first] = {self.first,self.headpos[1]+self.snakeDir.x*3,self.headpos[2]+self.snakeDir.y*3,false}
		end
		self.first = self.first - 1
	end

	-- pos of the rocker's center

	-- add rocker and its bg, speed up button
	self._rocker_bg = ccui.Button:create():addTo(self)
	self._rocker = ccui.Button:create():addTo(self)
	_a = ccui.Button:create("rock.png"):addTo(self):setOpacity(0)

	-- put button at right of the screen
	local rockerDot = display.newDrawNode():center():setPosition(cc.p(0,0)):addTo(self._rocker)
	rockerDot:drawDot(cc.p(0,0), 35, cc.c4f(0.4,0.4,0.4,0.7))

	local rockerBgDot = display.newDrawNode():center():setPosition(cc.p(0,0)):addTo(self._rocker_bg)
	rockerBgDot:drawDot(cc.p(0,0), 80, cc.c4f(0.4,0.4,0.4,0.4))

	local _aDot = display.newDrawNode():center():setPosition(cc.p(0,0)):addTo(_a)
	_aDot:drawDot(cc.p(38,38), 50, cc.c4f(0.4,0.4,0.4,0.55))

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

	self:getScheduler():scheduleScriptFunc(function()

    	self.PosList.first = self.PosList.first - 1 
    	local movement = 3
    	local jud = false
    	if speedUp then
    		jud = true
    		movement = 6
    	end
    	self.PosList[self.PosList.first] = {self.first,self.PosList[self.PosList.first+1][2]+self.snakeDir.x*movement,self.PosList[self.PosList.first+1][3]+self.snakeDir.y*movement,jud}
    	if jud then
    		self.first = self.first-1
    	end
    	self.first = self.first-1
    	if self.PosList[self.PosList.last] then
	    	self.PosList[self.PosList.last] = nil
    		self.PosList.last = self.PosList.last - 1 
    	end

    end,0,false)

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

function JoyRocker:getShadow()
	local list = {}
	local index = self.PosList.first
	for i = 1,15 do
		list[i] = self.PosList[index]
		index = index+1
	end
	return list
end

function JoyRocker:getSpeedUp()
	return speedUp
end

function JoyRocker:getSnakeDir()

	local x1,y1 = self.PosList[self.PosList.last][2],self.PosList[self.PosList.last][3]
	local x2,y2 = self.PosList[self.PosList.last-1][2],self.PosList[self.PosList.last-1][3]
	return cc.pNormalize(cc.p(x2-x1,y2-y1))
end

return JoyRocker