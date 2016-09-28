
local MainScene = class("MainScene", function()
    return display.newScene("MainScene")
end)

-- the random points make snake grow
local points = {}

local dw = display.width
local dh = display.height

-- random add the point on screen
function addPoint(self)
	local dot = display.newDrawNode():addTo(self):center()
    dot:drawDot(cc.p(0,0), 2, cc.c4f(0,0,0,1.0))
    local px,py = dot:getPosition()
	dot:setPosition(math.random(-1*dw,dw)+px,math.random(-1*dh,dh)+py)
    table.insert(points,dot)
end

function MainScene:ctor()

	-- add joyRocker and snake
    local j = require("src.app.JoyRocker").new()
    local snak = require("src.app.Snake").new()


    -- change the bg color to grey
    cc.LayerColor:create(cc.c4b(235,235,235,255)):addTo(self):setScale(2)

    -- add 150 little dots
    for i = 1,600 do
    	addPoint(self)
    end

    self:addChild(snak)
    self:addChild(j)

    -- snake's length info
    local len = cc.ui.UILabel.new({
			UILabelType = 2,text = "Length: "..tostring(snak:getSnakeLen()),size = 32})
		:align(display.LEFT_TOP, 10, display.height-10)
		:setColor(cc.c4b(0,0,0,255))
		:addTo(self)

	-- at each fram, move the sanke with direciton from JoyRocker
	-- and calculate weather the snake eat the little dot
    self:getScheduler():scheduleScriptFunc(function(f)

    	-- Move the snake, with direction and weather speed up
    	snak:Move(snak,j:getSnakeDir(),j:getSpeedUp())

        local sx = snak:getHeadPos().x
        local sy = snak:getHeadPos().y

        self:setPosition(cc.p(dw/2-sx,dh/2-sy))
        j:setPosition(cc.p(sx-dw/2,sy-dh/2))
    	-- calculate little dot weahter close to snake's head
    	for key, p in pairs(points) do
    		local px,py = p:getPosition()
			if cc.pGetDistance(cc.p(px,py),cc.p(sx,sy)) < 16 then
				
				len:setString("Length: "..tostring(snak:getSnakeLen()))

				-- if snake could eat little dot, remove this dot and grow
				p:clear()

				addPoint(self)
				table.remove(points,key)

				snak:addSnakeLen()
				if snak:canAddLen() then
					snak:setAddSnake()
				end
			end
		end

    end,0,false)

end

function MainScene:onEnter()
end

function MainScene:onExit()
end

return MainScene