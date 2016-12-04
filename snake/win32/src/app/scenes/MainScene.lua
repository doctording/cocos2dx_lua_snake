
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

-- require相应的类
-- local Body = require("app.Body")
local Snake = require("app.Snake")
local Fence = require("app.Fence")
local AppleFactory = require("app.AppleFactory")
local BlockFactory = require("app.BlockFactory")

local MainScene = class("MainScene", function()
    return display.newScene("MainScene")
end)

local cMoveSpeed = 0.3
local rowBound = 5
local colBound = 8


function MainScene:onEnter() -- MainScene 加载执行

		self:CreateScoreBoard() -- 分数版

		self:ProcessInput() -- 鼠标touch事件
		self:ProcessKeyInput() -- 键盘控制

		self:Reset()

		--self.snake = Snake.new(self) -- 创建一条蛇
		--self.fence = Fence.new(rowBound, colBound, self)  -- 创建围墙

		local tick = function()
			if self.stage == "running" then

				self.snake:Update() -- 更新蛇

				local headX , headY = self.snake:GetHeadGrid()
				local headX , headY = self.snake:GetHeadGrid()
        
        local b, index = self.blocks:Hit(headX,headY)
        
        if self.fence:CheckCollide(headX,headY)
                or self.snake:CheckCollideSelf() 
                or b ~= nil
            then
					self.stage = "dead"
					self.snake:Blink(function()

								self:Reset()


								end)
				elseif self.apple:CheckCollide(headX,headY) then
						self.apple:Generate() -- 苹果重新产生

						self.snake:Grow() -- 蛇变长

						self.score = self.score + 1 -- 分数加1
						self:SetScore(self.score)
				end
			end

		end -- end tick

		cc.Director:getInstance():getScheduler():scheduleScriptFunc(
			 tick,cMoveSpeed,false)

end



local function vector2Dir(x, y)

	if math.abs(x) > math.abs(y) then
		if x < 0 then
			return "left"
		else
			return "right"
	 end

	else

		if y > 0 then
			return "up"
		else
			return "down"
	  end

	end

end

-- 鼠标点击事件处理
function MainScene:ProcessInput()

	local function onTouchBegan(touch, event)

		local location = touch:getLocation() -- 得到触摸点坐标(cocos2d-x 坐标)


-- 判断移动的方向
		local snakex , snakey = self.snake:GetHeadGrid()
		local snake_fx,snake_fy = Grid2Pos(snakex,snakey)
		local finalX = location.x - snake_fx
		local finalY = location.y - snake_fy

		local dir = vector2Dir(finalX, finalY)
	    print("now dir",dir)
		self.snake:setDir(dir) -- 设置蛇的移动方向

	end

	local listener = cc.EventListenerTouchOneByOne:create()
	listener:registerScriptHandler(onTouchBegan, cc.Handler.EVENT_TOUCH_BEGAN)
	local eventDispatcher = self:getEventDispatcher()
	eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self)

end


-- 按键事件处理
function MainScene:ProcessKeyInput()

	local function keyboardPressed(keyCode,event)

		-- up
		if keyCode == 28 then
				print("up")
				self.snake:setDir("up") -- 设置蛇的移动方向
		-- down
		elseif keyCode == 29 then
				print("down")
				self.snake:setDir("down") -- 设置蛇的移动方向
		--left
		elseif keyCode == 26 then
				print("left")
				self.snake:setDir("left") -- 设置蛇的移动方向
		--right
		elseif keyCode == 27 then
				print("right")
				self.snake:setDir("right") -- 设置蛇的移动方向
		--end

		-- P
     elseif keyCode == 139 then
          print("P -- Pause")
          local director = cc.Director:getInstance()
          director:pause() -- 暂停

      --end

      -- R
      elseif keyCode == 141 then
          local director = cc.Director:getInstance()
          director:resume() -- 恢复

      end
	end

	local listener = cc.EventListenerKeyboard:create()
	listener:registerScriptHandler(keyboardPressed, cc.Handler.EVENT_KEYBOARD_PRESSED)
	local eventDispatcher = self:getEventDispatcher()
	eventDispatcher:addEventListenerWithSceneGraphPriority(listener,self)

end


-- 游戏结束操作
function MainScene:Reset()
	if self.apple ~= nil then
		self.apple:Reset()
	end

	if self.fence ~= nil then
		self.fence:Reset()
	end

	if self.snake ~= nil then
		self.snake:Kill()
	end
	-- 添加障碍物
	if self.blocks ~= nil then
		self.blocks:Reset()
	end
	self.blocks = BlockFactory.new(self)
	self:Load()

	self.snake = Snake.new(self) -- 创建一条蛇
	self.fence = Fence.new(rowBound, colBound, self)  -- 创建围墙
	self.apple = AppleFactory.new(rowBound, colBound, self)  -- 创建apple

	self.stage = "running"
	self.score = 0
	self:SetScore(self.score)
end

-- 加载文件哌
function MainScene:Load()
	local f = assert(dofile("scene.lua"))
	
	self.blocks:Reset()
	
	for _,t in ipairs(f) do
		self.blocks:Add(t.x, t.y, t.index)
	end
	
	print("main Loaded")
end

-- 创建显示分数
function MainScene:CreateScoreBoard()

	display.newSprite("applesign.png")
	:pos(display.right - 200 , display.cy + 150)
	:addTo(self)

	local ttfConfig = {}
	ttfConfig.fontFilePath = "arial.ttf"
	ttfConfig.fontSize = 30

	local score = cc.Label:createWithTTF(ttfConfig, "0")
	self:addChild(score)

	score:setPosition(display.right - 200 , display.cy + 80)

	self.scoreLabel = score

end

-- 设置分数
function MainScene:SetScore(s)
	self.scoreLabel:setString(string.format("%d",s))
end

return MainScene
