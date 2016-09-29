-- by kaysar, 2016-9-26
local MainScene = class("MainScene", function()
    return display.newScene("MainScene")
end)

local dw = display.width
local dh = display.height

local heads = {}

function MainScene:ctor()

	-- add joyRocker and snake
    local j = require("src.app.JoyRocker").new()

    local Snake = require("src.app.Snake")
    local snak = Snake.new()
    local snak2 =Snake.new()

    local food = require("src.app.Food").new()

    -- change the bg color to grey
    cc.LayerColor:create(cc.c4b(120,120,120,255)):addTo(self):setScale(6)
    cc.LayerColor:create(cc.c4b(235,235,235,255)):addTo(self):setScale(4)
    
    self:addChild(food)    
    self:addChild(snak)
    self:addChild(snak2)
    self:addChild(j)

    table.insert(heads,snak:getHeadPos())
    table.insert(heads,snak2:getHeadPos())


	-- at each fram, move the sanke with direciton from JoyRocker
	-- and calculate weather the snake eat the little dot
    self:getScheduler():scheduleScriptFunc(function(f)

    	-- Move the snake, with direction and weather speed up

        local sx = snak:getHeadPos().x
        local sy = snak:getHeadPos().y

        snak:Move(snak,j:getSnakeDir(),j:getSpeedUp(),heads)
        snak2:Move(snak2,cc.p(1,0),false,heads)

        if ((sx < -1.5*dw+9 or sx > 2.5*dw-9)or(sy < -1.5*dh+9 or sy > 2.5*dh-9)) then
            display.pause()
        end

        self:setPosition(cc.p(dw/2-sx,dh/2-sy))
        j:setPosition(cc.p(sx-dw/2,sy-dh/2))
        
        for i = 1,food:eatFood(sx, sy, food) do
            snak:addSnakeLen()
            if snak:canAddLen() then
                snak:setAddSnake()
            end
        end

    end,0,false)

end

function MainScene:onEnter()
end

function MainScene:onExit()
end

return MainScene