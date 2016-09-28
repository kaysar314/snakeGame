local Food = class("Food", function()
	
	return display.newLayer("Food")
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
	dot:setPosition(math.random(-1*dw/2,dw/2)+px,math.random(-1*dh/2,dh/2)+py)
    table.insert(points,dot)
end

function MainScene:ctor()

	 cc.LayerColor:create(cc.c4b(235,235,235,255)):addTo(self)

	for i = 1,150 do
    	addPoint(self)
    end

end

return Snake