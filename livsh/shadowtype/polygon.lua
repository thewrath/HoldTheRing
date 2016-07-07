local Polygon = {}

function Polygon:setShadowType(...)
	local args = {...}
	self.data = next(args) and args or {0, 0, 0, 0, 0, 0}
end

function Polygon:Paint()
	love.graphics.polygon("fill", self:getVertices())
end

return Polygon