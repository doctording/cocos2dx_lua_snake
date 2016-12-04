
local Body = class("Body")

-- node为cocos2dx-父节点
function Body:ctor(snake , x, y, node, isHead)

	self.snake = snake
	self.X = x
	self.Y = y
	
	if isHead then -- 根据是否是头部,用不同的图片创建 
		self.sp = cc.Sprite:create("head.png")
	else
		self.sp = cc.Sprite:create("body.png")
	end
	
	node:addChild(self.sp)
	
	self:Update()
	
end

-- 更新自己的位置
function Body:Update()
	
	local posx,posy = Grid2Pos(self.X , self.Y)
	self.sp:setPosition(posx,posy)
end

return Body