-- by kaysar, 2016-9-28
local Snake = class("Snake", function()
	return display.newLayer("Snake")
end)

-- speed up button down speedUp will be true, weather be false
-- local speedUp = false

-- the position of Snake's head
-- local headPos = cc.p(0,0)

-- snake's body, make with lots of dots


-- every dot of snake has 4 directions
-- store in a queue, every time JoyRocker get a direction, 
-- insert it in the front of queue, and remove the last direction
-- local DirectionList = {first = 0, last = -1}

-- length of snake, a dot's length is 5
-- local snakeLen = 20

-- storing the length of snake when it grows one more dot
-- for knowing when it has 5 more length grows
-- local snakeLastLen = 20

-- when need to growing one dot for snake, this will be true
-- local addSnake = false

-- real-time snake's direction, from JoyRocker
-- local snakeDir = cc.p(1,0)
-- cc.pNormalize(snakeDir)

function Snake:ctor()

	self.addSnake = false
	self.snakeLastLen = 20
	self.snakeLen = 20
	self.headPos = cc.p(0,0)
	self.snake = {}
	self.DirectionList = {first = 0, last = -1}
	-- ues to change dot's color
	self.changeColor = false

	-- at first, there are 4 dots for snake's body
	for i = 1,4 do
		local dot = display.newDrawNode():addTo(self):center()

		-- weather need to change color
		if self.changeColor then
			self.changeColor = false
			dot:drawDot(cc.p(0,0), 9, cc.c4f(0.4,0.5,0,1.0))
		else
			dot:drawDot(cc.p(0,0), 9, cc.c4f(0,0.6,0.7,1.0))
			self.changeColor = true
		end

		-- put the snake's one dot at right of last one
		local px,py = dot:getPosition()
		dot:setPosition(px+12*i,py)
		table.insert(self.snake, 1, dot)
	end

	-- init the directions of each snake's dot, 
	-- each dot has 4 direction
	-- this will change snake's direction one by one
	for i = 1,16 do
		List.pushFront(self.DirectionList,cc.pNormalize(cc.p(1,0)))
	end

end

-- at each frame call this func once, deal with sanke's movtion
function Snake:Move(self,snakeDir,speedUp,heads)

	local px,py = nil,nil
	local hitHead = {}
	local jud = false

	-- at mainscene call to growing
	if self.addSnake then
		addLength(self)
		self.addSnake = false
	end

	-- each frame get the direction from JoyRocker
	-- and push to Direction queue, remove the end of queue
	List.pushFront(self.DirectionList,snakeDir)
	List.popBack(self.DirectionList)

	-- at mainscene get the speedUp button's state
	-- if speedUp is true, then in every frame, will move twice,
	-- so this move need two direction to move twice
	if speedUp then
		jud = true
		List.pushFront(self.DirectionList,snakeDir)
		List.popBack(self.DirectionList)
	end
	
	-- index is the postion of direction at now
	local index = self.DirectionList.first

	-- loop to deal with each dot of snake, and let it move
	for key, dot in pairs(self.snake) do
		px,py = dot:getPosition()
		for hkey,hp in pairs(heads) do
			-- print(cc.pGetDistance(cc.p(px,py),cc.p(hp.x,hp.y)))
			-- if 16 > cc.pGetDistance(cc.p(px,py),cc.p(hp.x,hp.y)) then
			-- 	table.insert(hitHead,hkey)
			-- end
		end
		if self.DirectionList[index] ~= nil then

			-- let the dot move at the current direction
			dot:setPosition(cc.p(px+self.DirectionList[index].x*3,py+self.DirectionList[index].y*3))
			
			-- speedUp is true, then move twice
			if jud then
				index = index + 1
				px,py = dot:getPosition()
				dot:setPosition(cc.p(px+self.DirectionList[index].x*3,py+self.DirectionList[index].y*3))
			end
		end
		
		-- update the postion of snake's head
		if key == 1 then
			xx,yy = dot:getPosition()
			self.headPos = cc.p(xx,yy)
		end

		-- swith to next dot's direction
		-- each dot has 4, but when speed up, it'll use 2 directions
		if jud then
		index = index + 3
		else
			index = index + 4
   		end
   	end

   	return hitHead

end

-- snake grows one dot
local col = false -- weather change color
function addLength(self)

	-- get the last dot of snake, and copy one of it
	local tmp = self.snake[table.getn(self.snake)]
	local tmp2 = self.snake[table.getn(self.snake)-1]

	local dot = display.newDrawNode():addTo(self):center()

	-- change the color
	if col then
		dot:drawDot(cc.p(0,0), 9, cc.c4f(0,0.6,0.7,1.0))
		col = false
	else
		dot:drawDot(cc.p(0,0), 9, cc.c4f(0.4,0.5,0,1.0))
		col = true
	end

	-- get the last one's direction, for new dot's pos and dir
	local dirtmp = self.DirectionList[self.DirectionList.last-3]

	-- put the new one behind the original snake's last one
	local px,py = tmp:getPosition()	

	dot:setPosition(cc.p(px-dirtmp.x*12,py-dirtmp.y*12))

	-- add 4 directions for the new dot
	local last = self.DirectionList.last
	for i =1,4 do
		self.DirectionList[last+1-i] = dirtmp
		List.pushBack(self.DirectionList,dirtmp)
	end
	table.insert(self.snake, dot)

end

function Snake:getHeadPos()
	return self.headPos
end

function Snake:getSnakeLen()
	return self.snakeLen
end

function Snake:getSnakeLastLen()
	return self.snakeLastLen
end

function Snake:addSnakeLen()
	self.snakeLen = self.snakeLen + 1 
end

-- call in mainscene for check weather can grow
-- if could gorw, then update snake last length and return true
-- or return false
function Snake:canAddLen()
	if self.snakeLen - self.snakeLastLen > 4 then
		self.snakeLastLen = self.snakeLen
		return true
	end

	return false
end

-- change the local boolean "addSnake" 
-- to grow snake at Move() func
function Snake:setAddSnake()
	self.addSnake = true 
end


-- a queue id need to sotre the directions
-- because of lots of insert/remove, table is not good for it
List = {} 
-- first and last is 2 postion of head and end of queue
function List.new()  
    return {first = 0,last = -1}  
end  
  
-- insert at front  
function List.pushFront(list,value)  
    local first = list.first - 1  
    list.first = first  
    list[first] = value  
end  

-- insert at back
function List.pushBack(list,value)  
    local last = list.last + 1  
    list.last = last  
    list[last] = value
end  

-- remove at front  
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

-- remove at back 
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

return Snake