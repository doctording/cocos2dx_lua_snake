local AppleFactory = class("AppleFactory")

function AppleFactory:ctor(rowBound, colBound, node)

	self.rowBound = rowBound
	self.colBound = colBound
	self.node = node

	math.randomseed(os.time())

	self:Generate()

end


local function getRandomPos(rowBound,colBound)
	local randomX = math.random(-colBound, colBound)
	local randomY = math.random(-rowBound, rowBound)
	return randomX, randomY
end


function AppleFactory:Generate()

	if self.appleSprite ~= nil then
		self.node:removeChild(self.appleSprite) -- Ïú»Ù¶ÔÏó
	end


	local sp = cc.Sprite:create("apple.png")

	local x, y = getRandomPos(self.rowBound - 1, self.colBound-1)

	local finalX, finalY = Grid2Pos(x,y)
	sp:setPosition(finalX, finalY)

	self.node:addChild(sp)

	self.appleX = x
	self.appleY = y

	self.appleSprite = sp

end


function AppleFactory:CheckCollide(x,y)

	if x == self.appleX and y == self.appleY then
		return true
	end

	return false
end

function AppleFactory:Reset()

	self.node:removeChild(self.appleSprite)

end

return AppleFactory
