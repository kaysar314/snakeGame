
local MainScene = class("MainScene", function()
    return display.newScene("MainScene")
end)

local points = {}

function addPoint(self)
	local dot = display.newDrawNode():addTo(self):center()
    dot:drawDot(cc.p(0,0), 2, cc.c4f(0,0,0,1.0))
    local px,py = dot:getPosition()
	dot:setPosition(math.random(-1*display.width/2,display.width/2)+px,math.random(-1*display.height/2,display.height/2)+py)
    table.insert(points,dot)
end

function MainScene:ctor()

    local j = require("src.app.JoyRocker").new()

    cc.LayerColor:create(cc.c4b(235,235,235,255)):addTo(self)

    for i = 1,150 do
    	addPoint(self)
    end

    self:addChild(j)

    local len = cc.ui.UILabel.new({
			UILabelType = 2,text = "Length: "..tostring(j:getSnakeLen()),size = 32})
		:align(display.LEFT_TOP, 10, display.height-10)
		:setColor(cc.c4b(0,0,0,255))
		:addTo(self)


    self:getScheduler():scheduleScriptFunc(function(f)

    	for key, p in pairs(points) do
    		px,py = p:getPosition()
    		sx,sy = j:getHeadPos()
			if cc.pGetDistance(cc.p(px,py),cc.p(sx,sy)) < 16 then
				
				len:setString("Length: "..tostring(j:getSnakeLen()))

				p:clear()
				addPoint(self)
				table.remove(points,key)

				j:addSnakeLen()
				if j:canAddLen() then
					j:setAddSnake()
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
