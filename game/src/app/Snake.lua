-- by kaysar, 2016-9-28
local Snake = class("Snake", function()
	return display.newLayer("Snake")
end)

function Snake:ctor(col,pos,fir,times)

	if col == nil then
		for t = 1,(math.fmod(times,100)) do
			self.color = randomColor()
		end
	else
		self.color = col
	end
	-- when need to growing one dot for snake, this will be true
	self.addSnake = false

	-- storing the length of snake when it grows one more dot
	-- for knowing when it has 5 more length grows
	self.snakeLastLen = 64

	-- length of snake, a dot's length is 5
	self.snakeLen = 64

	-- the position of Snake's head
	self.headPos = {}

	-- snake's body, make with lots of dots
	self.snake = {first = 0, last = -1}

	self.live = true

	-- every dot of snake has 4 directions
	-- store in a queue, every time JoyRocker get a direction, 
	-- insert it in the front of queue, and remove the last direction
	self.DirectionList = {first = 0, last = -1}

	self.shadowList = {first = 0,last = -1}

	local cl = randomColor()
	-- at first, there are 4 dots for snake's body
	if pos == nil then
		for i = 1,32 do
			local dot = display.newDrawNode():addTo(self,-1*i+1):center()
			-- weather need to change color
			-- dot:drawDot(cc.p(0,0), 15, self.color)
			dot:drawSolidCircle(cc.p(0,0), 15, math.rad(90), 20, self.color)
			-- put the snake's one dot at right of last one
			local px,py = dot:getPosition()
			dot:setPosition(px+3*i,py)
			List.pushBack(self.snake,dot)
		end
	else
		self.snake = {first = fir, last = fir-1}
		for i = 1, #pos do
			local dot = display.newDrawNode():addTo(self,-1*i+1):center()
			-- weather need to change color
			dot:drawDot(cc.p(0,0), 15, self.color)
			-- put the snake's one dot at right of last one
			dot:setPosition(pos[i][1],pos[i][2])
			List.pushBack(self.snake,dot)
		end
	end

	local xx,yy = self.snake[self.snake.first]:getPosition()

	self.headPos = {self.snake.first-3,xx-9,yy}
	-- local xx,yy = self.snakePos[1]
	-- if self.snakePos[1] ~= nil then
	-- 	self.headPos = cc.p(self.snakePos[1][1],self.snakePos[1][2])
	-- end
	
	-- init the directions of each snake's dot, 
	-- each dot has 4 direction
	-- this will change snake's direction one by one
	
	

	for i = 1,3 do
		List.pushFront(self.shadowList,{self.snake.first-i,xx-3*i,yy})
	end
end

function Snake:ReBorn()

	self.live = true

	self.snakeLastLen = 64

	-- length of snake, a dot's length is 5
	self.snakeLen = 64
	self.shadowList = {first = 0,last = -1}
	self.snake = {first = 0, last = -1}
	-- the position of Snake's head
	self.headPos = cc.p(0,0)

	for i = 1,32 do
		local dot = display.newDrawNode():addTo(self,-1*i+1):center()
		-- weather need to change color
		-- dot:drawDot(cc.p(0,0), 15, self.color)
		dot:drawSolidCircle(cc.p(0,0), 15, math.rad(90), 20, self.color)
		-- put the snake's one dot at right of last one
		local px,py = dot:getPosition()
		dot:setPosition(px+3*i,py)
		List.pushBack(self.snake,dot)
	end

	local xx,yy = self.snake[self.snake.first]:getPosition()

	self.headPos = {self.snake.first-3,xx-9,yy}

	for i = 1,3 do
		List.pushFront(self.shadowList,{self.snake.first-i,xx-3*i,yy})
	end

end

function Snake:getLive()
	return self.live
end

function Snake:Dead()

	for index = self.snake.first,self.snake.last do
		self.snake[index]:clear()
		table.remove(self.snake,index)
	end

	self.live = false

	self.snakeLastLen = 0

	-- length of snake, a dot's length is 5
	self.snakeLen = 0

	-- the position of Snake's head
	-- self.headPos = cc.p(0,0)

	-- snake's body, make with lots of dots
	self.snake = {first = 0, last = -1}

	-- every dot of snake has 4 directions
	-- store in a queue, every time JoyRocker get a direction, 
	-- insert it in the front of queue, and remove the last direction
end

function Snake:OtherMove(self,pos)
	if self.addSnake then
		addLength(self)
		self.addSnake = false
	end

	local xx,yy = self.snake[1]:getPosition()
	self.headPos = cc.p(xx,yy)

	for i = 1, #self.snake do
		-- self.snake[i]:runAction(cc.moveTo:create(0.04, cc.p(pos[i][1],pos[i][2])))
		self.snake[i]:setPosition(cc.p(pos[i][1],pos[i][2]))
		self.snakePos[i] = pos[i]
	end
	if #pos > #self.snake then
		for i = #self.snake+1, #pos do
			local dot = display.newDrawNode():addTo(self):center()
			-- weather need to change color
			if self.changeColor then
				
				self.changeColor = false
				dot:drawDot(cc.p(0,0), 15, self.color1)
			else
				dot:drawDot(cc.p(0,0), 15, self.color2)
				self.changeColor = true
			end
			-- put the snake's one dot at right of last one
			dot:setPosition(pos[i][1],pos[i][2])
			table.insert(self.snake, dot) 
			table.insert(self.snakePos, pos[i])
		end 
	end
end

-- at each frame call this func once, deal with sanke's movtion
function Snake:Move(self,speedUp,largeStep)

	local px,py = nil,nil

	-- at mainscene call to growing
	-- if self.addSnake then
	-- 	addLength(self)
	-- 	self.addSnake = false
	-- end

	-- each frame get the direction from JoyRocker
	-- and push to Direction queue, remove the end of queue
	-- List.pushFront(self.shadowList,snakeDir)
	if self.shadowList.last >= self.shadowList.first then

		local xx,yy = self.shadowList[self.shadowList.last][2],self.shadowList[self.shadowList.last][3]
		local fx,fy = self.snake[self.snake.first]:getPosition()
		if self.shadowList[self.shadowList.last][4] then

			List.pushFront(self.snake,List.popBack(self.snake))
			self.snake[self.snake.first]:setPosition(cc.p((xx+fx)/2,(yy+fy)/2))

			List.pushFront(self.snake,List.popBack(self.snake))
			self.snake[self.snake.first]:setPosition(cc.p(xx,yy))
		else
			List.pushFront(self.snake,List.popBack(self.snake))
			self.snake[self.snake.first]:setPosition(cc.p(xx,yy))
		end
	
		self.headPos = {self.snake.first,xx,yy}

		List.popBack(self.shadowList)
	end
	
	-- at mainscene get the speedUp button's state
	-- if speedUp is true, then in every frame, will move twice,
	-- so this move need two direction to move twice
	
	-- index is the postion of direction at now
	-- local index = self.DirectionList.first
	-- -- loop to deal with each dot of snake, and let it move
	-- for key, dot in pairs(self.snake) do
	-- 	px,py = dot:getPosition()

	-- 	if self.DirectionList[index] ~= nil then

	-- 		local movement = 3
	-- 		-- speedUp is true, then move twice
	-- 		if speedUp then
	-- 			movement = 6
	-- 		end
	-- 		-- let the dot move at the current direction
	-- 		dot:setPosition(cc.p(px+self.DirectionList[index].x*movement,py+self.DirectionList[index].y*movement))
	-- 	end
		
	-- 	-- update the postion of snake's head
	-- 	if key == 1 then
	-- 		xx,yy = dot:getPosition()
	-- 		self.headPos = cc.p(xx,yy)
	-- 	end

	-- 	-- swith to next dot's direction
	-- 	index = index + 1

 --   		self.snakePos[key][1],self.snakePos[key][2] = dot:getPosition()
 --   	end
end

function Snake:addShadow(list)
	for i = 1,15 do
		if self.shadowList.last >= self.shadowList.first then
			if self.shadowList[self.shadowList.first][1] == list[15-i+1][1] + 1 then
				List.pushFront(self.shadowList,list[15-i+1])
			else 
				if self.shadowList[self.shadowList.first][1] == list[15-i+1][1] + 2 then
					List.pushFront(self.shadowList,list[15-i+1])
				end
			end
			if self.shadowList.last - self.shadowList.first > 12 then
				List.popBack(self.shadowList)
			end
		else
			if self.snake.first > list[15-i+1][1] then
				List.pushFront(self.shadowList,list[15-i+1])
			end
		end
	end
end

-- snake grows one dot
function Snake:addLength(self)

	-- get the last dot of snake, and copy one of it
	local tmp = self.snake[self.snake.last]

	local dot = display.newDrawNode():addTo(self,-1*(self.snakeLastLen)):center()

	-- change the color
	dot:drawSolidCircle(cc.p(0,0), 15, math.rad(90), 20, self.color)

	-- get the last one's direction, for new dot's pos and dir
	-- local dirtmp = self.DirectionList[self.DirectionList.last]

	-- -- put the new one behind the original snake's last one
	local px,py = tmp:getPosition()	
	dot:setPosition(cc.p(px,py))

	List.pushBack(self.snake,dot)

	-- add 4 directions for the new dot
	-- local last = self.DirectionList.last

	-- self.DirectionList[last] = dirtmp
	-- List.pushBack(self.DirectionList,dirtmp)

	-- table.insert(self.snake, dot)
	-- local dx,dy = dot:getPosition()
	-- table.insert(self.snakePos, {dx,dy})

end

function Snake:getHeadPos()
	return self.headPos
end

function Snake:getColor()
	return self.color
end

function Snake:getSnakeFir()
	return self.snake.first
end

function Snake:getSnakeShadow()

	local list = {}
	local index = self.shadowList.first
	for i = 1,(self.shadowList.last - self.shadowList.first + 1) do
		list[i] = self.shadowList[index]
		index = index+1
	end
	return list

end

function Snake:getBodyPos()
	local list = {}
	local index = self.snake.first
	for i = 1,(self.snake.last - self.snake.first + 1) do
		list[i] = {}
		list[i][1],list[i][2] = self.snake[index]:getPosition()
		index = index+1
	end
	return list
end

-- function Snake:getDirectionList()

-- 	local list = {}
-- 	local index = self.DirectionList.first
-- 	for i = 1,(self.DirectionList.last - self.DirectionList.first + 1) do
-- 		list[i] = self.DirectionList[index]
-- 		index = index+1
-- 	end
-- 	return list
-- end

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
	if self.snakeLen - self.snakeLastLen > 1 then
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

function randomColor()
	math.randomseed(tostring(os.time()):reverse():sub(1, 6))
	return cc.c4b(math.random(100,250),math.random(100,250),math.random(100,250),1.0)
end

return Snake