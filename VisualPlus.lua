-- VISUALPLUS UI v1.3
local VisualPlus = {}

local CoreGui      = game:GetService("CoreGui")
local UIS          = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Players      = game:GetService("Players")
local Lighting     = game:GetService("Lighting")

local Theme = {
	Bg      = Color3.fromRGB(15, 15, 19),
	Bg2     = Color3.fromRGB(22, 22, 28),
	Panel   = Color3.fromRGB(28, 28, 36),
	Hover   = Color3.fromRGB(38, 38, 48),
	Stroke  = Color3.fromRGB(44, 44, 56),
	Text    = Color3.fromRGB(232, 232, 240),
	TextDim = Color3.fromRGB(140, 140, 156),
	Accent  = Color3.fromRGB(130, 120, 255),
	Good    = Color3.fromRGB(90, 200, 130),
	Bad     = Color3.fromRGB(220, 90, 100),
}
VisualPlus.Theme = Theme

local function cr(parent, radius)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, radius or 10)
	c.Parent = parent
	return c
end

local function strk(parent, color, thickness, transparency)
	local s = Instance.new("UIStroke")
	s.Color = color or Theme.Stroke
	s.Thickness = thickness or 1
	s.Transparency = transparency or 0
	s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	s.Parent = parent
	return s
end

local function tw(inst, time, props)
	local t = TweenService:Create(inst, TweenInfo.new(time or 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props)
	t:Play()
	return t
end

-- NOTIFY
local notifyGui = nil
local notifyStack = {}

local function getNotifyGui()
	if notifyGui and notifyGui.Parent then return notifyGui end
	local g = Instance.new("ScreenGui")
	g.Name = "VisualPlusNotify"
	g.ResetOnSpawn = false
	g.DisplayOrder = 200
	g.Parent = CoreGui
	notifyGui = g
	return g
end

function VisualPlus:Notify(opts)
	opts = opts or {}
	local title = opts.Title or "Notification"
	local text = opts.Text or ""
	local duration = opts.Duration or 4

	local g = getNotifyGui()
	local holder = Instance.new("Frame")
	holder.Size = UDim2.new(0, 300, 0, 60)
	holder.Position = UDim2.new(1, -320, 0, 0)
	holder.BackgroundColor3 = Theme.Bg2
	holder.BackgroundTransparency = 0.05
	holder.BorderSizePixel = 0
	holder.Parent = g
	cr(holder, 10)
	strk(holder, Theme.Stroke, 1)

	local accent = Instance.new("Frame")
	accent.Size = UDim2.new(0, 3, 0.7, 0)
	accent.Position = UDim2.new(0, 0, 0.15, 0)
	accent.BackgroundColor3 = Theme.Accent
	accent.BorderSizePixel = 0
	accent.Parent = holder
	cr(accent, 2)

	local tLbl = Instance.new("TextLabel")
	tLbl.Size = UDim2.new(1, -20, 0, 18)
	tLbl.Position = UDim2.new(0, 14, 0, 8)
	tLbl.BackgroundTransparency = 1
	tLbl.Text = title
	tLbl.TextColor3 = Theme.Text
	tLbl.Font = Enum.Font.GothamBold
	tLbl.TextSize = 13
	tLbl.TextXAlignment = Enum.TextXAlignment.Left
	tLbl.Parent = holder

	local xLbl = Instance.new("TextLabel")
	xLbl.Size = UDim2.new(1, -20, 0, 24)
	xLbl.Position = UDim2.new(0, 14, 0, 26)
	xLbl.BackgroundTransparency = 1
	xLbl.Text = text
	xLbl.TextColor3 = Theme.TextDim
	xLbl.Font = Enum.Font.Gotham
	xLbl.TextSize = 12
	xLbl.TextXAlignment = Enum.TextXAlignment.Left
	xLbl.TextWrapped = true
	xLbl.Parent = holder

	table.insert(notifyStack, holder)

	local function relayout()
		local y = 20
		for i = #notifyStack, 1, -1 do
			local h = notifyStack[i]
			h.Position = UDim2.new(1, -320, 0, y)
			y = y + h.AbsoluteSize.Y + 10
		end
	end
	relayout()

	holder.Position = UDim2.new(1, 20, holder.Position.Y.Scale, holder.Position.Y.Offset)
	tw(holder, 0.3, {Position = UDim2.new(1, -320, holder.Position.Y.Scale, holder.Position.Y.Offset)})

	task.delay(duration, function()
		tw(holder, 0.3, {Position = UDim2.new(1, 20, holder.Position.Y.Scale, holder.Position.Y.Offset)})
		task.wait(0.3)
		for i, h in ipairs(notifyStack) do
			if h == holder then table.remove(notifyStack, i) break end
		end
		holder:Destroy()
		relayout()
	end)
end

-- WINDOW
function VisualPlus:CreateWindow(opts)
	opts = opts or {}
	local title    = opts.Title or "VisualPlus"
	local subtitle = opts.Subtitle or "v1.3"
	local size     = opts.Size or UDim2.fromOffset(720, 460)

	local win = {
		Tabs = {},
		Options = {},
		ActiveTab = nil,
		Visible = true,
		ToggleKey = opts.ToggleKey or "RightShift",
	}

	local gui = Instance.new("ScreenGui")
	gui.Name = "VisualPlusUI"
	gui.ResetOnSpawn = false
	gui.IgnoreGuiInset = true
	gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	gui.DisplayOrder = 100
	gui.Parent = CoreGui

	local blur = Instance.new("BlurEffect")
	blur.Size = 0
	blur.Parent = Lighting

	local main = Instance.new("Frame")
	main.Name = "Main"
	main.AnchorPoint = Vector2.new(0.5, 0.5)
	main.Position = UDim2.new(0.5, 0, 0.5, 0)
	main.Size = UDim2.fromOffset(0, 0)
	main.BackgroundColor3 = Theme.Bg
	main.BorderSizePixel = 0
	main.ClipsDescendants = true
	main.Parent = gui
	cr(main, 12)
	strk(main, Theme.Stroke, 1)

	local titlebar = Instance.new("Frame")
	titlebar.Name = "Titlebar"
	titlebar.Size = UDim2.new(1, 0, 0, 44)
	titlebar.BackgroundTransparency = 1
	titlebar.Parent = main

	local titleLbl = Instance.new("TextLabel")
	titleLbl.Size = UDim2.new(1, -160, 1, 0)
	titleLbl.Position = UDim2.new(0, 18, 0, 0)
	titleLbl.BackgroundTransparency = 1
	titleLbl.Text = title
	titleLbl.TextColor3 = Theme.Text
	titleLbl.Font = Enum.Font.GothamBold
	titleLbl.TextSize = 15
	titleLbl.TextXAlignment = Enum.TextXAlignment.Left
	titleLbl.Parent = titlebar

	local subLbl = Instance.new("TextLabel")
	subLbl.Size = UDim2.new(0, 200, 1, 0)
	subLbl.Position = UDim2.new(1, -260, 0, 0)
	subLbl.BackgroundTransparency = 1
	subLbl.Text = subtitle
	subLbl.TextColor3 = Theme.TextDim
	subLbl.Font = Enum.Font.Gotham
	subLbl.TextSize = 12
	subLbl.TextXAlignment = Enum.TextXAlignment.Right
	subLbl.Parent = titlebar

	local btnMin = Instance.new("TextButton")
	btnMin.Size = UDim2.new(0, 28, 0, 28)
	btnMin.Position = UDim2.new(1, -72, 0, 8)
	btnMin.BackgroundColor3 = Theme.Panel
	btnMin.Text = "—"
	btnMin.TextColor3 = Theme.TextDim
	btnMin.Font = Enum.Font.GothamBold
	btnMin.TextSize = 14
	btnMin.BorderSizePixel = 0
	btnMin.AutoButtonColor = false
	btnMin.Parent = titlebar
	cr(btnMin, 6)

	btnMin.MouseEnter:Connect(function() tw(btnMin, 0.15, {BackgroundColor3 = Theme.Hover}) end)
	btnMin.MouseLeave:Connect(function() tw(btnMin, 0.15, {BackgroundColor3 = Theme.Panel}) end)

	local btnClose = Instance.new("TextButton")
	btnClose.Size = UDim2.new(0, 28, 0, 28)
	btnClose.Position = UDim2.new(1, -40, 0, 8)
	btnClose.BackgroundColor3 = Theme.Panel
	btnClose.Text = "✕"
	btnClose.TextColor3 = Theme.TextDim
	btnClose.Font = Enum.Font.GothamBold
	btnClose.TextSize = 14
	btnClose.BorderSizePixel = 0
	btnClose.AutoButtonColor = false
	btnClose.Parent = titlebar
	cr(btnClose, 6)

	btnClose.MouseEnter:Connect(function() tw(btnClose, 0.15, {BackgroundColor3 = Theme.Bad, TextColor3 = Color3.new(1,1,1)}) end)
	btnClose.MouseLeave:Connect(function() tw(btnClose, 0.15, {BackgroundColor3 = Theme.Panel, TextColor3 = Theme.TextDim}) end)

	local sidebar = Instance.new("Frame")
	sidebar.Name = "Sidebar"
	sidebar.Size = UDim2.new(0, 180, 1, -58)
	sidebar.Position = UDim2.new(0, 12, 0, 48)
	sidebar.BackgroundColor3 = Theme.Bg2
	sidebar.BorderSizePixel = 0
	sidebar.Parent = main
	cr(sidebar, 10)
	strk(sidebar, Theme.Stroke, 1)

	local sidebarScroll = Instance.new("ScrollingFrame")
	sidebarScroll.Size = UDim2.new(1, -8, 1, -8)
	sidebarScroll.Position = UDim2.new(0, 4, 0, 4)
	sidebarScroll.BackgroundTransparency = 1
	sidebarScroll.BorderSizePixel = 0
	sidebarScroll.ScrollBarThickness = 2
	sidebarScroll.ScrollBarImageColor3 = Theme.Stroke
	sidebarScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
	sidebarScroll.Parent = sidebar

	local content = Instance.new("Frame")
	content.Name = "Content"
	content.Size = UDim2.new(1, -204, 1, -58)
	content.Position = UDim2.new(0, 204, 0, 48)
	content.BackgroundTransparency = 1
	content.Parent = main

	win.Gui = gui
	win.Main = main
	win.Sidebar = sidebar
	win.Content = content
	win.Titlebar = titlebar
	win.Blur = blur

	local dragging, dragStart, startPos
	titlebar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			dragStart = input.Position
			startPos = main.Position
		end
	end)
	UIS.InputChanged:Connect(function(input)
		if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			local d = input.Position - dragStart
			main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
		end
	end)
	UIS.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
	end)

	local minimized = false
	btnMin.MouseButton1Click:Connect(function()
		minimized = not minimized
		if minimized then
			win._savedSize = main.Size
			tw(main, 0.3, {Size = UDim2.fromOffset(300, 44)})
			sidebar.Visible = false
			content.Visible = false
		else
			tw(main, 0.3, {Size = win._savedSize or size})
			sidebar.Visible = true
			content.Visible = true
		end
	end)

	btnClose.MouseButton1Click:Connect(function()
		win.Visible = false
		tw(main, 0.3, {Size = UDim2.fromOffset(0, 0)})
		tw(blur, 0.3, {Size = 0})
		task.delay(0.35, function() gui.Enabled = false end)
	end)

	function win:Toggle(state)
		if state == nil then state = not win.Visible end
		if state then
			win.Visible = true
			gui.Enabled = true
			main.Visible = true
			tw(main, 0.35, {Size = size})
			tw(blur, 0.35, {Size = 8})
		else
			win.Visible = false
			tw(main, 0.35, {Size = UDim2.fromOffset(0, 0)})
			tw(blur, 0.35, {Size = 0})
			task.delay(0.35, function()
				if not win.Visible then gui.Enabled = false end
			end)
		end
	end

	local currentToggleKey = win.ToggleKey

	function win:SetToggleKey(newKey)
		currentToggleKey = newKey
		win.ToggleKey = newKey
	end

	function win:GetToggleKey()
		return currentToggleKey
	end

	UIS.InputBegan:Connect(function(input, gp)
		if input.UserInputType == Enum.UserInputType.Keyboard
			and input.KeyCode.Name == currentToggleKey then
			win:Toggle()
		end
	end)

	tw(main, 0.4, {Size = size})
	tw(blur, 0.4, {Size = 8})

	function win:AddTab(tabOpts)
		tabOpts = tabOpts or {}
		local tabName = tabOpts.Name or "Tab"

		local tabBtn = Instance.new("TextButton")
		tabBtn.Size = UDim2.new(1, 0, 0, 36)
		tabBtn.Position = UDim2.new(0, 0, 0, #win.Tabs * 40)
		tabBtn.BackgroundColor3 = Theme.Panel
		tabBtn.BackgroundTransparency = 1
		tabBtn.Text = ""
		tabBtn.BorderSizePixel = 0
		tabBtn.AutoButtonColor = false
		tabBtn.Parent = sidebarScroll
		cr(tabBtn, 7)

		local iconImg = nil
		if tabOpts.Icon then
			iconImg = Instance.new("ImageLabel")
			iconImg.Size = UDim2.new(0, 16, 0, 16)
			iconImg.Position = UDim2.new(0, 12, 0.5, -8)
			iconImg.BackgroundTransparency = 1
			iconImg.Image = tabOpts.Icon
			iconImg.ImageColor3 = Theme.TextDim
			iconImg.Parent = tabBtn
		end

		local tabText = Instance.new("TextLabel")
		tabText.Size = UDim2.new(1, -40, 1, 0)
		tabText.Position = UDim2.new(0, (iconImg and 34 or 14), 0, 0)
		tabText.BackgroundTransparency = 1
		tabText.Text = tabName
		tabText.TextColor3 = Theme.TextDim
		tabText.Font = Enum.Font.GothamMedium
		tabText.TextSize = 13
		tabText.TextXAlignment = Enum.TextXAlignment.Left
		tabText.Parent = tabBtn

		local indicator = Instance.new("Frame")
		indicator.Size = UDim2.new(0, 3, 0.5, 0)
		indicator.Position = UDim2.new(0, 0, 0.25, 0)
		indicator.BackgroundColor3 = Theme.Accent
		indicator.BackgroundTransparency = 1
		indicator.BorderSizePixel = 0
		indicator.Parent = tabBtn
		cr(indicator, 2)

		local tabPage = Instance.new("ScrollingFrame")
		tabPage.Size = UDim2.new(1, 0, 1, 0)
		tabPage.BackgroundTransparency = 1
		tabPage.BorderSizePixel = 0
		tabPage.ScrollBarThickness = 3
		tabPage.ScrollBarImageColor3 = Theme.Stroke
		tabPage.CanvasSize = UDim2.new(0, 0, 0, 0)
		tabPage.Visible = false
		tabPage.Parent = content

		local tab = {
			Name = tabName,
			Button = tabBtn,
			Indicator = indicator,
			Page = tabPage,
			Sections = {},
			Text = tabText,
			Icon = iconImg,
		}
		table.insert(win.Tabs, tab)

		tabBtn.MouseEnter:Connect(function()
			if tab ~= win.ActiveTab then tw(tabBtn, 0.15, {BackgroundTransparency = 0.6}) end
		end)
		tabBtn.MouseLeave:Connect(function()
			if tab ~= win.ActiveTab then tw(tabBtn, 0.15, {BackgroundTransparency = 1}) end
		end)

		tabBtn.MouseButton1Click:Connect(function()
			if win.ActiveTab and win.ActiveTab ~= tab then
				win.ActiveTab.Page.Visible = false
				tw(win.ActiveTab.Button, 0.15, {BackgroundTransparency = 1})
				if win.ActiveTab.Text then tw(win.ActiveTab.Text, 0.15, {TextColor3 = Theme.TextDim}) end
				if win.ActiveTab.Icon then tw(win.ActiveTab.Icon, 0.15, {ImageColor3 = Theme.TextDim}) end
				tw(win.ActiveTab.Indicator, 0.15, {BackgroundTransparency = 1})
			end
			win.ActiveTab = tab
			tab.Page.Visible = true
			tw(tabBtn, 0.15, {BackgroundTransparency = 0, BackgroundColor3 = Theme.Panel})
			if tabText then tw(tabText, 0.15, {TextColor3 = Theme.Text}) end
			if iconImg then tw(iconImg, 0.15, {ImageColor3 = Theme.Accent}) end
			tw(indicator, 0.15, {BackgroundTransparency = 0})
		end)

		sidebarScroll.CanvasSize = UDim2.new(0, 0, 0, #win.Tabs * 40)

		if #win.Tabs == 1 then
			win.ActiveTab = tab
			tab.Page.Visible = true
			tabBtn.BackgroundTransparency = 0
			tabBtn.BackgroundColor3 = Theme.Panel
			if tabText then tabText.TextColor3 = Theme.Text end
			if iconImg then iconImg.ImageColor3 = Theme.Accent end
			indicator.BackgroundTransparency = 0
		end

		function tab:AddSection(secOpts)
			secOpts = secOpts or {}
			local secName = secOpts.Name or ""

			local sec = {
				Name = secName,
				Height = (secName ~= "" and 40 or 16),
				Controls = {},
				_y = (secName ~= "" and 34 or 10),
			}

			local holder = Instance.new("Frame")
			holder.Size = UDim2.new(1, -20, 0, sec.Height)
			holder.BackgroundColor3 = Theme.Bg2
			holder.BorderSizePixel = 0
			holder.Parent = tabPage
			cr(holder, 10)
			strk(holder, Theme.Stroke, 1)
			sec.Holder = holder

			if secName ~= "" then
				local secLabel = Instance.new("TextLabel")
				secLabel.Size = UDim2.new(1, -24, 0, 18)
				secLabel.Position = UDim2.new(0, 14, 0, 10)
				secLabel.BackgroundTransparency = 1
				secLabel.Text = secName
				secLabel.TextColor3 = Theme.Text
				secLabel.Font = Enum.Font.GothamBold
				secLabel.TextSize = 13
				secLabel.TextXAlignment = Enum.TextXAlignment.Left
				secLabel.Parent = holder
			end

			table.insert(tab.Sections, sec)

			local function relayout()
				local y = 10
				for _, s in ipairs(tab.Sections) do
					s.Holder.Position = UDim2.new(0, 10, 0, y)
					y = y + s.Height + 10
				end
				tabPage.CanvasSize = UDim2.new(0, 0, 0, y + 10)
			end

			local function fitControl(h)
				sec._y = sec._y + h + 8
				if sec._y + 8 > sec.Height then
					sec.Height = sec._y + 8
					holder.Size = UDim2.new(1, -20, 0, sec.Height)
					relayout()
				end
			end

			local function controlY() return sec._y end

			function sec:AddButton(btnOpts)
				btnOpts = btnOpts or {}
				local h = 34
				local btn = Instance.new("TextButton")
				btn.Size = UDim2.new(1, -24, 0, h)
				btn.Position = UDim2.new(0, 12, 0, controlY())
				btn.BackgroundColor3 = Theme.Panel
				btn.Text = btnOpts.Text or "Button"
				btn.TextColor3 = Theme.Text
				btn.Font = Enum.Font.GothamMedium
				btn.TextSize = 13
				btn.BorderSizePixel = 0
				btn.AutoButtonColor = false
				btn.Parent = holder
				cr(btn, 7)
				strk(btn, Theme.Stroke, 1)

				btn.MouseEnter:Connect(function() tw(btn, 0.15, {BackgroundColor3 = Theme.Hover}) end)
				btn.MouseLeave:Connect(function() tw(btn, 0.15, {BackgroundColor3 = Theme.Panel}) end)
				btn.MouseButton1Click:Connect(function()
					if btnOpts.Callback then
						local ok, err = pcall(btnOpts.Callback)
						if not ok then warn("[VisualPlus] Button:", err) end
					end
				end)

				fitControl(h)
				return btn
			end

			function sec:AddToggle(name, tglOpts)
				tglOpts = tglOpts or {}
				local state = tglOpts.Default or false
				local h = 30
				local row = Instance.new("Frame")
				row.Size = UDim2.new(1, -24, 0, h)
				row.Position = UDim2.new(0, 12, 0, controlY())
				row.BackgroundTransparency = 1
				row.Parent = holder

				local lbl = Instance.new("TextLabel")
				lbl.Size = UDim2.new(1, -60, 1, 0)
				lbl.BackgroundTransparency = 1
				lbl.Text = name
				lbl.TextColor3 = Theme.Text
				lbl.Font = Enum.Font.GothamMedium
				lbl.TextSize = 13
				lbl.TextXAlignment = Enum.TextXAlignment.Left
				lbl.Parent = row

				local sw = Instance.new("Frame")
				sw.Size = UDim2.new(0, 36, 0, 20)
				sw.Position = UDim2.new(1, -36, 0.5, -10)
				sw.BackgroundColor3 = state and Theme.Accent or Theme.Stroke
				sw.BorderSizePixel = 0
				sw.Parent = row
				cr(sw, 10)

				local knob = Instance.new("Frame")
				knob.Size = UDim2.new(0, 16, 0, 16)
				knob.Position = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
				knob.BackgroundColor3 = Color3.fromRGB(245, 245, 250)
				knob.BorderSizePixel = 0
				knob.Parent = sw
				cr(knob, 8)

				local btn = Instance.new("TextButton")
				btn.Size = UDim2.new(1, 0, 1, 0)
				btn.BackgroundTransparency = 1
				btn.Text = ""
				btn.Parent = row

				local function setState(v)
					state = v
					tw(sw, 0.2, {BackgroundColor3 = state and Theme.Accent or Theme.Stroke})
					tw(knob, 0.2, {Position = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)})
					if tglOpts.Callback then
						local ok, err = pcall(tglOpts.Callback, state)
						if not ok then warn("[VisualPlus] Toggle:", err) end
					end
				end

				btn.MouseButton1Click:Connect(function() setState(not state) end)

				local obj = {Value = state, SetValue = setState}
				win.Options[name] = obj
				fitControl(h)
				return obj
			end

			function sec:AddSlider(name, slOpts)
				slOpts = slOpts or {}
				local min = slOpts.Min or 0
				local max = slOpts.Max or 100
				local value = slOpts.Default or min
				local h = 42
				local row = Instance.new("Frame")
				row.Size = UDim2.new(1, -24, 0, h)
				row.Position = UDim2.new(0, 12, 0, controlY())
				row.BackgroundTransparency = 1
				row.Parent = holder

				local lbl = Instance.new("TextLabel")
				lbl.Size = UDim2.new(1, -70, 0, 16)
				lbl.BackgroundTransparency = 1
				lbl.Text = name
				lbl.TextColor3 = Theme.Text
				lbl.Font = Enum.Font.GothamMedium
				lbl.TextSize = 13
				lbl.TextXAlignment = Enum.TextXAlignment.Left
				lbl.Parent = row

				local valLbl = Instance.new("TextLabel")
				valLbl.Size = UDim2.new(0, 60, 0, 16)
				valLbl.Position = UDim2.new(1, -60, 0, 0)
				valLbl.BackgroundTransparency = 1
				valLbl.Text = tostring(value)
				valLbl.TextColor3 = Theme.Accent
				valLbl.Font = Enum.Font.GothamBold
				valLbl.TextSize = 13
				valLbl.TextXAlignment = Enum.TextXAlignment.Right
				valLbl.Parent = row

				local track = Instance.new("Frame")
				track.Size = UDim2.new(1, 0, 0, 6)
				track.Position = UDim2.new(0, 0, 0, 26)
				track.BackgroundColor3 = Theme.Stroke
				track.BorderSizePixel = 0
				track.Parent = row
				cr(track, 3)

				local fill = Instance.new("Frame")
				fill.Size = UDim2.new((value - min) / (max - min), 0, 1, 0)
				fill.BackgroundColor3 = Theme.Accent
				fill.BorderSizePixel = 0
				fill.Parent = track
				cr(fill, 3)

				local knob = Instance.new("Frame")
				knob.Size = UDim2.new(0, 14, 0, 14)
				knob.AnchorPoint = Vector2.new(0.5, 0.5)
				knob.Position = UDim2.new((value - min) / (max - min), 0, 0.5, 0)
				knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				knob.BorderSizePixel = 0
				knob.Parent = track
				cr(knob, 7)
				strk(knob, Theme.Accent, 2)

				local dragging = false
				local function setVal(v, fire)
					v = math.clamp(v, min, max)
					if slOpts.Rounding then
						local mult = 10 ^ slOpts.Rounding
						v = math.floor(v * mult + 0.5) / mult
					else
						v = math.floor(v + 0.5)
					end
					value = v
					local r = (v - min) / (max - min)
					fill.Size = UDim2.new(r, 0, 1, 0)
					knob.Position = UDim2.new(r, 0, 0.5, 0)
					valLbl.Text = tostring(v)
					if fire and slOpts.Callback then
						local ok, err = pcall(slOpts.Callback, v)
						if not ok then warn("[VisualPlus] Slider:", err) end
					end
				end

				local function update(mx)
					local pos = track.AbsolutePosition.X
					local sz = track.AbsoluteSize.X
					if sz <= 0 then return end
					local p = math.clamp((mx - pos) / sz, 0, 1)
					setVal(min + (max - min) * p, true)
				end

				track.InputBegan:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 then
						dragging = true
						update(input.Position.X)
					end
				end)
				UIS.InputChanged:Connect(function(input)
					if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
						update(input.Position.X)
					end
				end)
				UIS.InputEnded:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
				end)

				local obj = {Value = value, SetValue = function(v) setVal(v, true) end}
				win.Options[name] = obj
				fitControl(h)
				return obj
			end

			function sec:AddDropdown(name, ddOpts)
				ddOpts = ddOpts or {}
				local values = ddOpts.Values or {}
				local selected = ddOpts.Default or values[1] or "—"
				local h = 34
				local row = Instance.new("Frame")
				row.Size = UDim2.new(1, -24, 0, h)
				row.Position = UDim2.new(0, 12, 0, controlY())
				row.BackgroundTransparency = 1
				row.ClipsDescendants = false
				row.ZIndex = 10
				row.Parent = holder

				local lbl = Instance.new("TextLabel")
				lbl.Size = UDim2.new(1, -150, 1, 0)
				lbl.BackgroundTransparency = 1
				lbl.Text = name
				lbl.TextColor3 = Theme.Text
				lbl.Font = Enum.Font.GothamMedium
				lbl.TextSize = 13
				lbl.TextXAlignment = Enum.TextXAlignment.Left
				lbl.Parent = row

				local ddBtn = Instance.new("TextButton")
				ddBtn.Size = UDim2.new(0, 140, 1, 0)
				ddBtn.Position = UDim2.new(1, -140, 0, 0)
				ddBtn.BackgroundColor3 = Theme.Panel
				ddBtn.Text = selected
				ddBtn.TextColor3 = Theme.Text
				ddBtn.Font = Enum.Font.GothamMedium
				ddBtn.TextSize = 12
				ddBtn.BorderSizePixel = 0
				ddBtn.AutoButtonColor = false
				ddBtn.ZIndex = 10
				ddBtn.Parent = row
				cr(ddBtn, 7)
				strk(ddBtn, Theme.Stroke, 1)

				local popup = Instance.new("Frame")
				popup.Size = UDim2.new(0, 140, 0, math.min(#values * 26 + 8, 160))
				popup.Position = UDim2.new(1, -140, 1, 4)
				popup.BackgroundColor3 = Theme.Panel
				popup.BorderSizePixel = 0
				popup.Visible = false
				popup.ZIndex = 50
				popup.Parent = row
				cr(popup, 7)
				strk(popup, Theme.Stroke, 1)

				local scroll = Instance.new("ScrollingFrame")
				scroll.Size = UDim2.new(1, -8, 1, -8)
				scroll.Position = UDim2.new(0, 4, 0, 4)
				scroll.BackgroundTransparency = 1
				scroll.BorderSizePixel = 0
				scroll.ScrollBarThickness = 2
				scroll.ScrollBarImageColor3 = Theme.Stroke
				scroll.CanvasSize = UDim2.new(0, 0, 0, #values * 26)
				scroll.ZIndex = 51
				scroll.Parent = popup

				local optsBtns = {}
				for i, v in ipairs(values) do
					local opt = Instance.new("TextButton")
					opt.Size = UDim2.new(1, 0, 0, 24)
					opt.Position = UDim2.new(0, 0, 0, (i - 1) * 26)
					opt.BackgroundColor3 = Theme.Panel
					opt.BackgroundTransparency = 1
					opt.Text = v
					opt.TextColor3 = Theme.Text
					opt.Font = Enum.Font.Gotham
					opt.TextSize = 12
					opt.BorderSizePixel = 0
					opt.AutoButtonColor = false
					opt.ZIndex = 52
					opt.Parent = scroll
					cr(opt, 5)

					opt.MouseEnter:Connect(function() tw(opt, 0.15, {BackgroundTransparency = 0.5}) end)
					opt.MouseLeave:Connect(function() tw(opt, 0.15, {BackgroundTransparency = 1}) end)
					opt.MouseButton1Click:Connect(function()
						selected = v
						ddBtn.Text = v
						popup.Visible = false
						if ddOpts.Callback then
							local ok, err = pcall(ddOpts.Callback, v)
							if not ok then warn("[VisualPlus] Dropdown:", err) end
						end
					end)
					table.insert(optsBtns, opt)
				end

				local open = false
				ddBtn.MouseButton1Click:Connect(function()
					open = not open
					popup.Visible = open
				end)

				local obj = {
					Value = selected,
					SetValue = function(v) selected = v; ddBtn.Text = v end,
				}
				win.Options[name] = obj
				fitControl(h)
				return obj
			end

			function sec:AddKeyPicker(name, kpOpts)
				kpOpts = kpOpts or {}
				local current = kpOpts.Default or "None"
				local h = 34
				local row = Instance.new("Frame")
				row.Size = UDim2.new(1, -24, 0, h)
				row.Position = UDim2.new(0, 12, 0, controlY())
				row.BackgroundTransparency = 1
				row.Parent = holder

				local lbl = Instance.new("TextLabel")
				lbl.Size = UDim2.new(1, -110, 1, 0)
				lbl.BackgroundTransparency = 1
				lbl.Text = name
				lbl.TextColor3 = Theme.Text
				lbl.Font = Enum.Font.GothamMedium
				lbl.TextSize = 13
				lbl.TextXAlignment = Enum.TextXAlignment.Left
				lbl.Parent = row

				local keyBtn = Instance.new("TextButton")
				keyBtn.Size = UDim2.new(0, 100, 1, 0)
				keyBtn.Position = UDim2.new(1, -100, 0, 0)
				keyBtn.BackgroundColor3 = Theme.Panel
				keyBtn.Text = current
				keyBtn.TextColor3 = Theme.Accent
				keyBtn.Font = Enum.Font.GothamBold
				keyBtn.TextSize = 12
				keyBtn.BorderSizePixel = 0
				keyBtn.AutoButtonColor = false
				keyBtn.Parent = row
				cr(keyBtn, 7)
				strk(keyBtn, Theme.Stroke, 1)

				local waiting = false
				local conn = nil
				keyBtn.MouseButton1Click:Connect(function()
					if waiting then return end
					waiting = true
					keyBtn.Text = "..."
					conn = UIS.InputBegan:Connect(function(input)
						if input.UserInputType == Enum.UserInputType.Keyboard then
							current = input.KeyCode.Name
							keyBtn.Text = current
							waiting = false
							if conn then conn:Disconnect() end
							if kpOpts.OnChanged then
								local ok, err = pcall(kpOpts.OnChanged, current)
								if not ok then warn("[VisualPlus] KeyPicker.OnChanged:", err) end
							end
						end
					end)
					task.delay(3, function()
						if waiting then
							waiting = false
							keyBtn.Text = current
							if conn then conn:Disconnect() end
						end
					end)
				end)

				if kpOpts.Callback then
					UIS.InputBegan:Connect(function(input, gp)
						if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode.Name == current then
							pcall(kpOpts.Callback)
						end
					end)
				end

				local obj = {Value = current}
				win.Options[name] = obj
				fitControl(h)
				return obj
			end

			relayout()
			return sec
		end

		return tab
	end

	return win
end

return VisualPlus
