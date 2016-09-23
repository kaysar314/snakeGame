local JoyRockerEvent = {
	A = "A",

	CANSEL_A = "CANSEL_A",

	LEFT="LEFT",
	RIGHT="RIGHT",

	CANSEL_LEFT = "CANSEL_LEFT",
	CANSEL_RIGHT = "CANSEL_RIGHT"
}

local JoyRocker = class("JoyRocker", function()
	return display.newLayer("JoyRocker")
end)

local _rockerRange = nil
local _rocker = nil
local _rocker_bg = nil
local _a = nil
local _b = nil

local snakeDir = cc.p(1,0)
cc.pNormalize(snakeDir)

local _rockerTouchID = -1
local _rockerDirection = 0.0
local _rockerLastPoint = 0

local _callback = nil

local _rockerRangeValue = 400

local function callback( event )
	if _callback ~= nil then
		_callback(event)
	end
end

local function touchEvent(obj, type)
	if type == ccui.TouchEventType.bagan then
		if obj == _a then
			callback(JoyRockerEvent.A)
		end
	elseif type == ccui.TouchEventType.ended then
		if obj == _a then
			callback(JoyRockerEvent.CANSEL_A)
		end
	elseif type == ccui.TouchEventType.cancelled then
		if obj == _a then
			callback(JoyRockerEvent.CANSEL_A)
		end
	end

end

function JoyRocker:ctor()

	local size = display.size
	local  _rockerX = _rockerRangeValue/2
	local  _rockerY = _rockerX

	local  snake = {}
	local  snakeDirs = {}
	for i = 1,20 do
		local dot = display.newDrawNode():addTo(self):center()
		dot:drawDot(cc.p(0,0), 10, cc.c4f(1.0,1.0,1.0,1.0))
		local px,py = dot:getPosition()
		dot:setPosition(px-15*i,py)
		table.insert(snake, 1, dot)
	end
	-- local dot = display.newDrawNode():addTo(self):center()
	-- dot:drawDot(cc.p(0,0), 10, cc.c4f(1.0,1.0,1.0,1.0))

	_rocker_bg = ccui.Button:create("rock_bg.png"):addTo(self)
	_rocker = ccui.Button:create("rock.png"):addTo(self)
	_rockerRange = ccui.Widget:create()
	_a = ccui.Button:create("rock.png")

	_rocker:setAnchorPoint(cc.p(0.5,0.5))

	-- _rockerRange:setContentSize(cc.size(_rockerRangeValue,_rocker:getContentSize().height))
	-- _rockerRange:setPosition(cc.p(_rockerX,0))

	--150 is not good, make it %
	_a:setPosition(cc.p(size.width-_a:getContentSize().width-150,0))

	_rocker_bg:setPosition(cc.p(_rockerX,_rockerY))
	_rocker_bg:setTouchEnabled(false)
	_rocker:setPosition(cc.p(_rockerX,_rockerY))
	_rocker:setTouchEnabled(false)
	-- _rockerRange:addChild(_rocker_bg)
	-- _rockerRange:addChild(_rocker)

	-- self:addChild(_rockerRange)
	self:addChild(_a)

	_a:addTouchEventListener(touchEvent)

	local event = cc.Director:getInstance():getEventDispatcher()
	local rockerDangeEvent = cc.EventListenerTouchOneByOne:create()

	rockerDangeEvent:registerScriptHandler(function(touch,e)
		
		local point = touch:getLocation()

		if cc.pGetDistance(cc.p(_rockerX,_rockerY),point) < 250 then
			_rockerTouchID = touch:getId()

			snakeDir = cc.p(_rockerX - point.x,_rockerY - point.y )
			snakeDir = cc.pNormalize(snakeDir)

			if 60 < cc.pGetDistance(cc.p(_rockerX,_rockerY),point) then
				_rocker:setPosition(cc.p(snakeDir.x*60+_rockerX,snakeDir.y*60+_rockerY))
			end

			return true
		end

		return false

	end,cc.Handler.EVENT_TOUCH_BEGAN)

	rockerDangeEvent:registerScriptHandler(function(touch,e)

		local point = touch:getLocation()

		if cc.pGetDistance(cc.p(_rockerX,_rockerY),point) < 250 then
			_rockerTouchID = touch:getId()

			snakeDir = cc.p(point.x - _rockerX, point.y - _rockerY)
			snakeDir = cc.pNormalize(snakeDir)

			if 60 < cc.pGetDistance(cc.p(_rockerX,_rockerY),point) then
				_rocker:setPosition(cc.p(snakeDir.x*60+_rockerX,snakeDir.y*60+_rockerY))
			else
				_rocker:setPosition(cc.p(point.x,point.y))
			end

			return true
		end

		return false
	end,cc.Handler.EVENT_TOUCH_MOVED)

	rockerDangeEvent:registerScriptHandler(function(touch,e)
		_rocker:setPosition(cc.p(_rockerX,_rockerY))
	end,cc.Handler.EVENT_TOUCH_ENDED)

	rockerDangeEvent:registerScriptHandler(function(touch,e)
		_rocker:setPosition(cc.p(_rockerX,_rockerY))
	end,cc.Handler.EVENT_TOUCH_CANCELLED)

	event:addEventListenerWithSceneGraphPriority(rockerDangeEvent, _rocker_bg)

	local count = 0

	self:getScheduler():scheduleScriptFunc(function(f)

		local tx,ty = nil,nil
		local px,py = nil,nil

		if count > 4 then
			count = 0
			for key, dot in pairs(snake) do
				if key == 1 then
					px,py = dot:getPosition()
					print("1: ",px,py,"\n")
					dot:setPosition(cc.p(px+snakeDir.x*4,py+snakeDir.y*4))
				else
					tx,ty = dot:getPosition()
					dot:setPosition(cc.p(px,py))
					px,py = tx,ty
					print(key,": ",px,py,"\n")
				end
			-- print(key,var)  
    		end
    	end
    	count = count + 1
	end,0,false)

end

function JoyRocker:setCallback(callback)
	_callback = callback
end

return JoyRocker