local MainScene = class("MainScene", function()
    return display.newScene("MainScene")
end)

function MainScene:ctor()

     local start_btn = cc.ui.UIPushButton.new({normal = "rock.png"}, {scale9 = true})
    start_btn:setScale(2.0)
    start_btn:setPosition(cc.p(display.cx - 200, display.cy + 120))
    self:addChild(start_btn, 0)

    start_btn:onButtonClicked(function(event)
        app:enterScene("GameScene", "SLIDEINT", 1.0)
    end)
end

function MainScene:onEnter()

end

function MainScene:onExit()

end

return MainScene