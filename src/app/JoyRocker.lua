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
local _a = nil
local _b = nil

local _rockerTouchID = -1
local _rockerWay = 0 -- 0 1 2
local _rockerLastPoint = 0

local _callback = nil

local _rockerRangeValue = 300

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

	_rockerRange = ccui.Widget:create()
	_rocker = ccui.Button:create("rock.png")
	_a = ccui.Button:create("rock.png")

	_rockerRange:setContentSize(cc.size(_rockerRangeValue,_rocker:getContentSize().height))

	_rockerRange:setPosition(cc.p(_rockerRangeValue/2,0))

	--150 is not good, make it %
	_a:setPosition(cc.p(size.width-_a:getContentSize().width-150,0))

	_rocker:setPosition(cc.p(_rockerRangeValue/2,_rocker:getContentSize().height/2))
	_rocker:setTouchEnabled(false)
	_rockerRange:addChild(_rocker)

	self:addChild(_rockerRange)
	self:addChild(_a)

	_a:addTouchEventListener(touchEvent)

	local event = cc.Director:getInstance():getEventDispatcher()
	local rockerDangeEvent = cc.EventListenerTouchOneByOne:create()

	rockerDangeEvent:registerScriptHandler(function(touch,e)
		
		local bound = _rockerRange:getBoundingBox()
		local newP = _rockerRange:convertToWorldSpace(cc.p(0,0))
		bound.x = newP.x
		bound.y = newP.y

		local point = touch:getLocation()

		if cc.rectContainsPoint(bound,point) then
			_rockerTouchID = touch:getId()

			_rockerLastPoint = point.x

			if math.abs(math.abs(point.x-bound.x)-_rockerRangeValue/2) < 20 then
				--dont move
			elseif point.x - bound.x > _rockerRangeValue/2 then
				-- right
				_rockerWay = 2
				callback(JoyRockerEvent.RIGHT)
			else 
				-- left
				-- right
				_rockerWay = 1
				callback(JoyRockerEvent.LEFT)
			end

			return true
		end

		return false

	end,cc.Handler.EVENT_TOUCH_BEGAN)

	rockerDangeEvent:registerScriptHandler(function(touch,e)
		
	end,cc.Handler.EVENT_TOUCH_MOVED)

	rockerDangeEvent:registerScriptHandler(function(touch,e)
		
	end,cc.Handler.EVENT_TOUCH_ENDED)

	rockerDangeEvent:registerScriptHandler(function(touch,e)
		
	end,cc.Handler.EVENT_TOUCH_CANCELLED)

	event:addEventListenerWithSceneGraphPriority(rockerDangeEvent, _rockerRange)

end

function JoyRocker:setCallback(callback)
	_callback = callback
end

return JoyRocker