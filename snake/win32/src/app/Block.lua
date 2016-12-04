local cGridSize = 33
local scaleRate = 1 / display.contentScaleFactor

-- 根据自定义的坐标得到实际应该显示的cocos2d-x坐标位置
function Grid2Pos(x,y)

	local visibleSize = cc.Director:getInstance():getVisibleSize() -- 获取整个手机可视屏幕尺寸

	local origin = cc.Director:getInstance():getVisibleOrigin() -- 获取手机可视屏原点的坐标,屏幕的左上角

	local finalX = origin.x + visibleSize.width / 2 + x * cGridSize * scaleRate
	local finalY = origin.y + visibleSize.height / 2 + y * cGridSize * scaleRate

	return finalX,finalY

end

local cMoveSpeed = 0.3
local rowBound = 5
local colBound = 8

-------------------------------------------

local Block = class("Block")

function Block:ctor(node)
	self.node = node
end

-- 设置当前的障碍物 index = 1,2,3 ..依据自己的障碍物图片数目
function Block:Set(index)

	if self.sp ~= nil then
		self.node:removeChild(self.sp)
	end	
	
	self.index = index 
	self.sp = display.newSprite(string.format("block%d.png",index)) --转换图片地址
	self.node:addChild(self.sp)
	
end

-- 设置位置
function Block:SetPos(x, y)
	local rbound = rowBound -1 
	local cbound = colBound -1 

	local posx , posy = Grid2Pos(x, y)	
	self.sp:setPosition(posx, posy)
			
	self.x = x
	self.y = y
	
end

-- 清除对象
function Block:Clear()
	self.node:removeChild(self.sp)
end

function Block:CheckCollide(x,y)

	if x == self.x and y == self.y then
		return true
	end

	return false
end

return Block