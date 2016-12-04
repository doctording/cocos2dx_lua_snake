
local BlockFactory = class("BlockFactory")

local Block = require("app.Block")


function BlockFactory:ctor(node)
	self.BlockArray = {} --障碍物集合
	self.node = node
	
end

-- 在x，y位置添加一个序号为index的障碍物
function BlockFactory:Add(x, y, index)
	local b = Block.new(self.node)
	
	b:Set(index)
	b:SetPos(x, y)
	table.insert(self.BlockArray,b)

end

function BlockFactory:Remove(x,y)
	local b,index = self:Hit(x,y)
	
	if b ~= nil then
		b:Clear()
		table.remove(self.BlockArray, index)
	end
	
end

function BlockFactory:Hit(x,y)
	for index, b in ipairs(self.BlockArray) do
		if b:CheckCollide(x, y) then
			return b, index
		end
	end
	
	return nil,-1
end

function BlockFactory:Reset()
	for _,b in ipairs(self.BlockArray) do
		b:Clear()
	end
end	

-- 写入文件
function BlockFactory:Save(f)

	for _,b in ipairs(self.BlockArray) do
		f:write(string.format("{x=%d,y=%d,index=%d},\n",b.x,b.y,b.index ))
	end
end

return BlockFactory