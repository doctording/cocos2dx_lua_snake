local Snake = class("Snake")

local Body = require("app.Body")

local cInitLen = 3 -- 蛇初始长度

-- 构造函数
function Snake:ctor(node)

	self.BodyArray = {} -- Body对象数组
	self.node = node
	self.MoveDir = "left" -- 蛇的初始移动方向

	for i = 1,cInitLen do
		self:Grow(i == 1)
	end

end


--取出蛇尾
function Snake:GetTailGrid()
	if #self.BodyArray == 0 then -- 设置蛇头的位置为(0,0)
		return 0,0
	end

	local tail = self.BodyArray[#self.BodyArray]

	return tail.X,tail.Y

end

-- 蛇变长
function Snake:Grow(isHead)

	local tailX,tailY = self:GetTailGrid()
	local body = Body.new(self,tailX,tailY,self.node,isHead)

	table.insert(self.BodyArray,body)

end

-- 根据方向改变坐标
local function OffsetGridByDir(x,y,dir)
	if dir == "left" then
		return x - 1, y
	elseif dir == "right" then
		return x + 1, y
	elseif dir == "up" then
		return x, y + 1
	elseif dir == "down" then
		return x, y - 1
	end

	print("Unkown dir", dir)
	return x, y
end


-- 根据蛇的移动方向 更新蛇，就是BodyArray一个一个往前移动
function Snake:Update()

	if #self.BodyArray == 0 then
		return
	end

	for i = #self.BodyArray , 1 , -1 do

		local body = self.BodyArray[i]

		if i == 1 then -- 蛇头位置 与 方向，得到一个新的位置 存放蛇头
			body.X, body.Y = OffsetGridByDir(body.X, body.Y, self.MoveDir)
		else
			local front = self.BodyArray[i-1]
			body.X, body.Y = front.X, front.Y
		end

		body:Update()

	end

end


-- 取出蛇头
function Snake:GetHeadGrid()
	if #self.BodyArray == 0 then
		return nil
	end

	local head = self.BodyArray[1]

	return head.X, head.Y

end

-- 设置方向
function Snake:setDir(dir)
		 local  hvTable = {
        ["left"] = "h",
        ["right"] = "h",
        ["up"] = "v",
        ["down"] = "v",
    }
    -- 水平 ，垂直的互斥
    if hvTable[dir] == hvTable[self.MoveDir] then
        return
    else
        self.MoveDir = dir
        
         -- 取出蛇头
        local head = self.BodyArray[1]

        -- 顺时针旋转，初始方向为left
        local rotTable ={
            ["left"] = 0,
            ["up"] = 90,
            ["right"] = 180,
            ["down"] = -90,
        }
        -- 让精灵图片旋转，以改变显示
        head.sp:setRotation(rotTable[self.MoveDir])
        
    end
end

-- 死亡之后的闪烁效果
function Snake:Blink(callback)

	for index,body in ipairs (self.BodyArray) do
		local blink = cc.Blink:create(3,5)

		if index == 1 then -- 蛇头
			local a = cc.Sequence:create(blink, cc.CallFunc:create(callback))
			body.sp:runAction(a)
		else
			body.sp:runAction(blink) -- 蛇身
		end

	end -- for

end

function Snake:Kill()
	for _,body in ipairs(self.BodyArray) do
		self.node:removeChild(body.sp)
	end
end

function Snake:CheckCollideSelf()
    if #self.BodyArray < 2 then
        return false
    end

    local headX, headY = self.BodyArray[1].X , self.BodyArray[1].Y

    for i = 2, #self.BodyArray do
        local body = self.BodyArray[i]

        if body.X == headX and body.Y == headY then
            return true;
        end
    end

    return false
end

return Snake
