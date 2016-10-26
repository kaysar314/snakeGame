-- by kaysar, 2016-9-26
local MainScene = class("MainScene", function()
    return display.newScene("MainScene")
end)

local dw = display.width
local dh = display.height

local snake = require("src.app.Snake")
local joy = require("src.app.JoyRocker")
local food = require("src.app.Food")
local createFood = false

local socket = require("socket")
local cjson = require("cjson")

local json = require("json")

local heads = {}

-- connect server
local host = "127.0.0.1"
local port = 6666
local sock = assert(socket.connect(host, port))
sock:settimeout(0)
local mip,mport = sock:getsockname()
local myName = tostring(mport)
print("connect server")

-- send data after first send
function sendData1st(self)
    local sendObj = {}
    sendObj["mySnakePos"] = self.mySnake:getBodyPos()
    sendObj["mySnakeFir"] = self.mySnake:getSnakeFir()
    sendObj["myShadows"] = self.myJoy:getShadow()
    sendObj["name"] = myName
    sendObj["color"] = self.mySnake:getColor()
    sendObj["type"] = "ctor"

    -- sendObj["live"] = self.mySnake:getLive()
    local sendStr = json.encode(sendObj)
    -- print("SEND:\n",sendStr,"\n\n")
    sock:send(sendStr.."\n")
    sendObj = {}
    local response, receive_status, partial = sock:receive()
    while response == nil do
        response, receive_status, partial = sock:receive()
    end
    if receive_status ~= "closed" then
        if response or partial then

            -- print("RECV:\n",response,"\n\n")
            local recvData = json.decode(response or partial)
            if recvData["food"] ~= 0 then
                self.myFood = food.new(recvData["food"]):addTo(self)
            else
                self.myFood = food.new():addTo(self,-4)
                self.myFoodPos = self.myFood:getFoodPos()
                createFood = true
                print("Create food")
            end

            for key, sn in pairs(recvData["data"]) do
                if key ~= myName then
                    -- local tmpSnake = snake.new(sn["color"],sn["snakePos"],sn["mySnakeFir"])
                    -- self.otherSnakes[key] = tmpSnake
                    -- self:addChild(tmpSnake)
                else
                    self.mySnake:addShadow(sn["myShadows"])
                end
            end
        end
    end

    sendObj["myShadows"] = self.myJoy:getShadow()
    sendObj["name"] = myName
    sendObj["type"] = "loop"
    sendObj["food"] = 0
    sendObj["live"] = self.mySnake:getLive()
    if createFood then
        sendObj["food"] = self.myFoodPos
        createFood = false
    end
    local sendStr = json.encode(sendObj) 
    -- print("SEND:\n",sendStr,"\n\n")
    sock:send(sendStr.."\n")
end

-- send data at first send
function sendData(self,sx,sy,headnum)

    local sendObj = {}

    local response, receive_status, partial = sock:receive()

    while response == nil do
        response, receive_status, partial = sock:receive()
    end

    if receive_status ~= "closed" then
        if response or partial then
            recvData = json.decode(response or partial)
            -- print("RECV:\n",response,"\n\n")
            for k,s in pairs(self.otherSnakes) do
                if recvData["data"][k] == nil then
                    self.otherSnakes[k]:Dead()
                    self.otherSnakes[k] = nil
                end
            end
            if recvData["type"] == "addNew" then
                sendObj["snakePos"] = self.mySnake:getBodyPos()
                sendObj["color"] = self.mySnake:getColor()
                sendObj["mySnakeFir"] = self.mySnake:getSnakeFir()
            end
            for key, sn in pairs(recvData["data"]) do
                if key == myName then
                    if self.mySnake:getLive() then
                        self.mySnake:addShadow(sn["myShadows"])
                        for i = 1,self.myFood:eatFood(sx,sy,self.myFood) do
                            self.mySnake:addSnakeLen()
                            if self.mySnake:canAddLen() then
                                self.mySnake:addLength(self.mySnake)
                            end
                        end
                    end
                else
                    if self.otherSnakes[key] == nil then
                        if sn["snakePos"] then
                            local tmpSnake = snake.new(sn["color"],sn["snakePos"],sn["mySnakeFir"])
                            self.otherSnakes[key] = tmpSnake
                            self:addChild(tmpSnake)
                            self.otherSnakes[key]:addShadow(sn["myShadows"])
                        else
                            if sendObj["addNew"] == nil then
                                sendObj["addNew"] = {}
                            end
                            table.insert(sendObj["addNew"],key)
                        end
                    else
                        -- self.headtime[key] = sn["headtime"]
                        self.otherSnakes[key]:addShadow(sn["myShadows"])
                        for key,p in pairs(self.otherSnakes[key]:getBodyPos()) do
                            if cc.pGetDistance(cc.p(sx,sy),cc.p(p[1],p[2])) < 20 then
                                self.myFood:addDeadPoint(self.myFood,self.mySnake:getBodyPos())
                                sendObj["snakePos"] = self.mySnake:getBodyPos()
                                self.mySnake:Dead()
                                break
                            end
                        end
                        if sn["live"] then
                            if self.otherSnakes[key]:getLive() == false then
                                self.otherSnakes[key]:ReBorn()
                            end
                            for i = 1,self.myFood:eatFood(self.otherSnakes[key]:getHeadPos()[2], self.otherSnakes[key]:getHeadPos()[3], self.myFood) do
                                self.otherSnakes[key]:addSnakeLen()
                                if self.otherSnakes[key]:canAddLen() then
                                    self.otherSnakes[key]:addLength(self.otherSnakes[key])
                                end
                            end
                        else 
                            if self.otherSnakes[key]:getLive() and sn["snakePos"] then
                                self.myFood:addDeadPoint(self.myFood,sn["snakePos"])
                                self.otherSnakes[key]:Dead()
                            end
                        end
                    end
                end     
            end
        end
    end

    sendObj["myShadows"] = self.myJoy:getShadow()
    sendObj["name"] = tostring(mport)
    sendObj["type"] = "loop"
    sendObj["food"] = 0
    sendObj["live"] = self.mySnake:getLive()
    sendObj["headtime"] = {headnum,socket:gettime()}
    if createFood then
        sendObj["food"] = self.myFoodPos
        createFood = false
    end
    local sendStr = json.encode(sendObj) 
    -- print("SEND:\n",sendStr,"\n\n")
    sock:send(sendStr.."\n")
end

function MainScene:ctor()
	-- add joyRocker and snake
    -- change the bg color to grey
    cc.LayerColor:create(cc.c4b(120,120,120,255)):addTo(self,-6):setScale(16)
    local map = cc.LayerColor:create(cc.c4b(235,235,235,255)):addTo(self,-5):setScale(4)

    self.otherSnakes = {}

    local dot = display.newDrawNode():addTo(self,3):center()
    dot:drawSolidCircle(cc.p(0,0), 13, math.rad(90), 30, cc.c4b(150,150,150,1.0))
    dot:drawDot(cc.p(6,6), 4, cc.c4b(0,0,0,1.0))
    dot:drawDot(cc.p(6,-6), 4, cc.c4b(0,0,0,1.0))

    self.mySnake = snake.new(nil,nil,nil,mport):addTo(self,0)
    self.myJoy = joy.new(self.mySnake:getHeadPos()):addTo(self,4)
    self.myFood = nil
    self.myFoodPos = {}
    self.recv = {}

    self.headtime = {}

    sendData1st(self)

    self:getScheduler():scheduleScriptFunc(function()
        if self.mySnake:getLive() == false then
            self.mySnake:ReBorn()
            self:removeChild(self.myJoy, true)
            self.myJoy = joy.new(self.mySnake:getHeadPos()):addTo(self,4)
        end
    end,3,false)

	-- at each fram, move the sanke with direciton from JoyRocker
	-- and calculate weather the snake eat the little dot
    self:getScheduler():scheduleScriptFunc(function()

        local sx = self.mySnake:getHeadPos()[2]
        local sy = self.mySnake:getHeadPos()[3]
        
        sendData(self,sx,sy,self.mySnake:getHeadPos()[1])

    	-- Move the snake, with direction and weather speed up

        -- get snake info that hit on the player

        -- if ((sx < -1.5*dw+9 or sx > 2.5*dw-9)or(sy < -1.5*dh+9 or sy > 2.5*dh-9)) then
        --     display.pause()
        -- end
    end,0.05,false)

    local count = 0

    self:getScheduler():scheduleScriptFunc(function()

        if self.mySnake:getLive() then
            self.mySnake:Move(self.mySnake,self.myJoy:getSpeedUp(self.myJoy))
        end

        local sx = self.mySnake:getHeadPos()[2]
        local sy = self.mySnake:getHeadPos()[3]

        dot:setPosition(cc.p(sx,sy))
        -- dot:setRotation()

        for k,s in pairs(self.otherSnakes) do
            if s:getLive() then
                s:Move(s,false,true)
                -- print(headtime[key])
                -- if headtime[key] and math.floor((socket:gettime()-headtime[key][1])/0.016)-(s:getHeadPos()[1]-headtime[key][2]) > 2 then
                --     s:Move(s,false,true)
                -- end
            end
        end

        -- if count < 200 then
        -- print(socket:gettime(),'\n\n')
        -- end
        self:setPosition(cc.p(dw/2-sx,dh/2-sy))
        self.myJoy:setPosition(cc.p(sx-dw/2,sy-dh/2))

    end,0,false)
end

function MainScene:onEnter()
end

function MainScene:onExit()
    sock.close()
end

return MainScene