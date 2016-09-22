
local MainScene = class("MainScene", function()
    return display.newScene("MainScene")
end)

function MainScene:ctor()
    
    local j = require("src.app.JoyRocker").new()

    self:addChild(j)

    j:setPositionY(display.height/3)

    j:setCallback(function(event)
    	print(event)
    end)

end

function MainScene:onEnter()
end

function MainScene:onExit()
end

return MainScene
