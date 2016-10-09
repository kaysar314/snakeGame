-- by kaysar, 2016-9-26
local MainScene = class("MainScene", function()
    return display.newScene("MainScene")
end)

local dw = display.width
local dh = display.height
local tcp = require("src.app.Tcp").new()

local heads = {}

function MainScene:ctor()

    tcp:connect("127.0.0.1",8080)

    -- self.tcp = assert(socket.tcp())
    -- self.tcp:settimeout(0)
    -- self.tcp:connect('127.0.0.1', 8080)
    -- -- self.tcp:send("hello")
    -- local count = 0
    -- self:getScheduler():scheduleScriptFunc(function(f)
    --     self.tcp:send("hello-"..tostring(count))
    --     local s, status, partial = self.tcp:receive()
    --     print("body: "..tostring(count),s or partial)
    --     print("status: "..tostring(count),status)
    --     count = count + 1
    -- end,0,false)


	-- add joyRocker and snake
    local j = require("src.app.JoyRocker").new()

    -- add 2 snake into the MainScene
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

        heads[1] = snak:getHeadPos()
        heads[2] = snak2:getHeadPos()

        tcp:send("heads00000")

        -- get snake info that hit on the player
        local headsTmp = heads
        headsTmp[1] = nil
        local hithead = snak:Move(snak,j:getSnakeDir(j),j:getSpeedUp(j),headsTmp)
        if hithead[1] ~= nil then print("hit 1!\n") end

        heads[1] = snak:getHeadPos()
        headsTmp = heads
        headsTmp[2] = nil
        local hithead = snak2:Move(snak2,cc.p(1,0),false,headsTmp)
        if hithead[1] ~= nil then print("hit 2!\n") end

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

function onStatus(__event)
    echoInfo("socket status: %s", __event.name)
end

function onData(__event)
    echoInfo("socket status: %s, data:%s", __event.name, ByteArray.toString(__event.data))
end

return MainScene