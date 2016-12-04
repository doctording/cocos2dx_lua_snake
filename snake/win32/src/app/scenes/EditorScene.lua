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


local Fence = require("app.Fence")
local Block = require("app.Block")
local BlockFactory = require("app.BlockFactory")

local EditorScene = class("EditorScene", function()
    return display.newScene("EditorScene")
end)

local cMaxBlock = 3 -- 障碍物数目 

function EditorScene:onEnter()
	self.fence = Fence.new(rowBound, colBound,self) --围墙
	
	-- 鼠标光标位置 初始化为左上角
	self.curX = 0
	self.curY = 0
	self.curIndex = 0 -- 选择的物体序号

	self:SwitchCursor(1)
	self:ProcessInput()
	self.blockFactory = BlockFactory.new(self)
	
end


-- 按键事件处理
function EditorScene:ProcessInput()
	
	local function keyboardPressed(keyCode,event)
		
		-- up
		if keyCode == 28 then
			self:MoveCursor(0,1)
		-- down
		elseif keyCode == 29 then
			self:MoveCursor(0,-1)
		--left
		elseif keyCode == 26 then
			self:MoveCursor(-1,0)
		--right
		elseif keyCode == 27 then
			self:MoveCursor(1,0)
		-- pageUp
		elseif keyCode == 38 then
			self:SwitchCursor(-1)
		-- pageDown
		elseif keyCode == 44 then
			self:SwitchCursor(1)

		
		-- enter
		elseif keyCode == 35 then
			self:Place()
		
		-- delete
		elseif keyCode == 23 then
			self:Delete()
		
		-- F3 加载文件
		elseif keyCode == 49 then 
			self:Load()
		-- F4 保存为文件
		elseif keyCode == 50 then
			self:Save()
		
		end
		
	end
	
	local listener = cc.EventListenerKeyboard:create()
	listener:registerScriptHandler(keyboardPressed, cc.Handler.EVENT_KEYBOARD_PRESSED)
	local eventDispatcher = self:getEventDispatcher()
	eventDispatcher:addEventListenerWithSceneGraphPriority(listener,self)
	
end

-- 上下左右 移动光标 
function EditorScene:MoveCursor(deltaX,deltaY)
	self.cur:SetPos(self.curX + deltaX, self.curY+deltaY)
	self.curX = self.cur.x
	self.curY = self.cur.y
	
end

-- 可以切换障碍物 delta=1 为下一个物体 ，-1 为上一个障碍物
function EditorScene:SwitchCursor(delta)
	if self.cur == nil then
	 	self.cur = Block.new(self)
	end
	
	local newIndex = self.curIndex + delta
	newIndex = math.max(newIndex, 1)
	newIndex = math.min(newIndex, cMaxBlock)
	
	self.curIndex = newIndex
	
	self.cur:Set(newIndex)
	self.cur:SetPos(self.curX, self.curY)
	
end

-- 放置一个物体
function EditorScene:Place()
	if self.blockFactory:Hit(self.cur.x,self.cur.y) then
		return
	end
	self.blockFactory:Add(self.curX, self.curY, self.cur.index)
end


-- 删除物体
function EditorScene:Delete()
	self.blockFactory:Remove(self.cur.x, self.cur.y)
end


-- lua文件存盘 F4
function EditorScene:Save()

	local f = assert(io.open("scene.lua", "w"))
	
	f:write("return {\n")
	self.blockFactory:Save(f)
	f:write("}\n")
	
	f:close()
	
	print("saved")
	
end

-- F3
function EditorScene:Load() 
	local f = assert(dofile("scene.lua"))
	
	self.blockFactory:Reset()
	
	for _,t in ipairs(f) do
		self.blockFactory:Add(t.x, t.y, t.index)
	end
	
	print("Loaded")
end

return EditorScene