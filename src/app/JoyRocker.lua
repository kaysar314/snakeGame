-- queen
List = {} 
function List.new()  
    return {first = 0,last = -1}  
end  
  
-- insert at front  
function List.pushFront(list,value)  
    local first = list.first - 1  
    list.first = first  
    list[first] = value  
end  

function List.pushBack(list,value)  
    local last = list.last + 1  
    list.last = last  
    list[last] = value
end  

function List.popFront(list)  
    local first = list.first  
    if first > list.last then  
        error("List is empty")  
    end  
      
    local value = list[first]  
    list[first] = nil  
    list.first = first + 1  
    return value  
end  
  
function List.popBack(list)  
    local last = list.last  
    if list.first > last then  
        error("List is empty")  
    end  
    local value = list[last]  
    list[last] = nil  
    list.last = last - 1   
    return value  
end 

local JoyRocker = class("JoyRocker", function()
	
	return display.newLayer("JoyRocker")
end)

local _rockerRange = nil
local _rocker = nil
local _rocker_bg = nil
local _a = nil
local _b = nil

local speedUp = false

local hadPos = cc.p(0,0)
local  snake = {}
local DirectionList = {first = 0, last = -1}
local snakeLen = 20
-- last
local snakeLastLen = 20
local addSnake = false

local count = 0

local snakeDir = cc.p(1,0)
cc.pNormalize(snakeDir)

local _rockerTouchID = -1
local _rockerDirection = 0.0
local _rockerLastPoint = 0

local _rockerRangeValue = 400

local function touchEvent(obj, type)
	if type == ccui.TouchEventType.began then
		if obj == _a then
			speedUp = true
		end
	elseif type == ccui.TouchEventType.ended then
		if obj == _a then
			speedUp = false
		end
	elseif type == 3 then
		if obj == _a then
			speedUp = false
		end
	end
end

function JoyRocker:ctor()

	local size = display.size
	local  _rockerX = _rockerRangeValue/2
	local  _rockerY = _rockerX

	local coun = false
	for i = 1,4 do
		local dot = display.newDrawNode():addTo(self):center()
		if coun then
			coun = false
			dot:drawDot(cc.p(0,0), 9, cc.c4f(0.4,0.5,0,1.0))
		else
			dot:drawDot(cc.p(0,0), 9, cc.c4f(0,0.6,0.7,1.0))
			coun = true
		end
		local px,py = dot:getPosition()
		dot:setPosition(px+12*i,py)
		table.insert(snake, 1, dot)
	end

	for i = 1,16 do
		List.pushFront(DirectionList,snakeDir)
	end
	_rocker_bg = ccui.Button:create("rock_bg.png"):addTo(self)
	_rocker = ccui.Button:create("rock.png"):addTo(self)
	_rockerRange = ccui.Widget:create()
	_a = ccui.Button:create("rock.png")

	_rocker:setAnchorPoint(cc.p(0.5,0.5))

	_a:setPosition(cc.p(size.width-_a:getContentSize().width-150,_rockerY))

	_rocker_bg:setPosition(cc.p(_rockerX,_rockerY))
	_rocker_bg:setTouchEnabled(false)
	_rocker:setPosition(cc.p(_rockerX,_rockerY))
	_rocker:setTouchEnabled(false)

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

		if cc.pGetDistance(cc.p(_rockerX,_rockerY),point) < 550 then
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

	self:getScheduler():scheduleScriptFunc(function(f)

		local tx,ty = nil,nil
		local px,py = nil,nil

		local jud = false

		if addSnake then
			addLength(self)
			addSnake = false
		end

		List.pushFront(DirectionList,snakeDir)
		List.popBack(DirectionList)

		if speedUp then
			jud = true
			List.pushFront(DirectionList,snakeDir)
			List.popBack(DirectionList)
		end
		
		index = DirectionList.first
		for key, dot in pairs(snake) do

			px,py = dot:getPosition()
			if DirectionList[index] ~= nil then
				dot:setPosition(cc.p(px+DirectionList[index].x*3,py+DirectionList[index].y*3))
				
				if jud then
					index = index + 1
					px,py = dot:getPosition()
					dot:setPosition(cc.p(px+DirectionList[index].x*3,py+DirectionList[index].y*3))
				end
			end
			
			if key == 1 then
				xx,yy = dot:getPosition()
				hadPos = cc.p(xx,yy)
			end

			if jud then
				index = index + 3
			else
				index = index + 4
    		end
    	end

	end,0,false)

end

local col = false

function addLength(self)
	local tmp = snake[table.getn(snake)]
	local dirtmp = DirectionList[DirectionList.last-3]

	local dot = display.newDrawNode():addTo(self):center()

	if col then
		dot:drawDot(cc.p(0,0), 9, cc.c4f(0,0.6,0.7,1.0))
		col = false
	else
		dot:drawDot(cc.p(0,0), 9, cc.c4f(0.4,0.5,0,1.0))
		col = true
	end

	px,py = tmp:getPosition()
	dot:setPosition(cc.p(px-dirtmp.x*12,py-dirtmp.y*12))

	for i =1,4 do
		List.pushBack(DirectionList,dirtmp)
	end
	table.insert(snake, dot)

end

function JoyRocker:getHeadPos()
	return hadPos
end

function JoyRocker:getSnakeLen()
	return snakeLen
end

function JoyRocker:getSnakeLastLen()
	return snakeLastLen
end

function JoyRocker:addSnakeLen()
	snakeLen = snakeLen + 1 
end

function JoyRocker:canAddLen()
	if snakeLen - snakeLastLen > 4 then
		snakeLastLen = snakeLen
		return true
	end

	return false
end

function JoyRocker:setAddSnake()
	addSnake = true 
end

return JoyRocker