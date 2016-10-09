-- by kaysar, 2016-9-29
local Food = class("Food", function()
	return display.newLayer("Food")
end)

-- the random points make snake grow
local dotpos = {}
-- the positon around head of snake
local eatPos = {-4,0,-3,-2,-3,-1,-3,0,-3,1,-3,2,-2,-3,-2,-2,-2,-1,-2,0,-2,1,-2,2,-2,3,-1,-3,-1,-2,-1,2,-1,3,0,-4,0,-3,0,-2,0,2,0,3,0,4,1,-3,1,-2,1,2,1,3,2,-3,2,-2,2,-1,2,0,2,1,2,2,2,3,3,-2,3,-1,3,0,3,1,3,2,4,0}

local dw = display.width
local dh = display.height

function Food:ctor()

	-- add 1600 food in game
	for i = 1,500 do
    	addPoint(self)
    end
end

-- eat food, call in MainScene
function Food:eatFood(sx,sy,self)

	-- change the head positon to food's world position
	sx = (math.floor(sx)-math.fmod(math.floor(sx), 4))/4
    sy = (math.floor(sy)-math.fmod(math.floor(sy), 4))/4

    -- record the food has been eat at one frame
    local foodSum = 0

    -- weather the positon near by head has food
    for i =1,40 do
    	-- change the position to string for serching in food tabel 
        local dotkey = tostring(sx+eatPos[i*2-1])..','..tostring(sy+eatPos[i*2])
        if dotpos[dotkey] ~= nil then
        	foodSum = foodSum + 1
            dotpos[dotkey]:clear()
            dotpos[dotkey] = nil
            addPoint(self)
        end
    end
    return foodSum
end

-- random add the point on screen
function addPoint(self)
	local dot = display.newDrawNode():addTo(self):center()
    dot:drawDot(cc.p(0,0), 2, randomColor())
    local px,py = dot:getPosition()
    local rx = math.floor(math.random(-dw*3/8,dw*5/8))
    local ry = math.floor(math.random(-dh*3/8,dh*5/8))
	dot:setPosition(rx*4,ry*4)
	-- add the new food in table, positon string as the key value
    dotpos[tostring(rx)..','..tostring(ry)] = dot
end

-- return a random color
function randomColor()
	return cc.c4b(math.random(100,255),math.random(100,255),math.random(100,255),1.0)
end

return Food