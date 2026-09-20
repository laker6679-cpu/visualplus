local VisualPlus = loadstring(game:HttpGet("https://raw.githubusercontent.com/laker6679-cpu/visualplus/main/VisualPlus.lua"))()

local Win = VisualPlus:CreateWindow({
	Title = "VisualPlus",
	Subtitle = "v1.2",
	ToggleKey = "RightShift",
})

-- ═══ MAIN ═══
local tabMain = Win:AddTab({Name = "Main", Icon = "rbxassetid://6031068420"})
local sec1 = tabMain:AddSection({Name = "General"})

sec1:AddButton({
	Text = "Say Hello",
	Callback = function()
		VisualPlus:Notify({Title = "Hello!", Text = "Работает!", Duration = 3})
	end,
})

sec1:AddToggle("Auto Farm", {
	Default = false,
	Callback = function(state)
		VisualPlus:Notify({Title = "Auto Farm", Text = state and "ON" or "OFF", Duration = 2})
	end,
})

sec1:AddSlider("WalkSpeed", {
	Min = 16, Max = 300, Default = 16,
	Callback = function(v)
		local ch = game.Players.LocalPlayer.Character
		if ch and ch:FindFirstChildOfClass("Humanoid") then
			ch:FindFirstChildOfClass("Humanoid").WalkSpeed = v
		end
	end,
})

-- ═══ VISUAL ═══
local tabVisual = Win:AddTab({Name = "Visual", Icon = "rbxassetid://6031075931"})
local sec2 = tabVisual:AddSection({Name = "Visual"})

sec2:AddDropdown("Glow Mode", {
	Values = {"Outline", "Neon", "Solid", "None"},
	Default = "Outline",
	Callback = function(v)
		VisualPlus:Notify({Title = "Режим", Text = v, Duration = 2})
	end,
})

sec2:AddSlider("Fade Time", {
	Min = 0, Max = 5, Default = 1.2, Rounding = 2,
	Callback = function(v) end,
})

-- ═══ SETTINGS ═══
local tabSettings = Win:AddTab({Name = "Settings", Icon = "rbxassetid://6031280882"})
local secKey = tabSettings:AddSection({Name = "UI Hotkey"})

secKey:AddKeyPicker("Клавиша открытия UI", {
	Default = "RightShift",
	OnChanged = function(newKey)
		Win:SetToggleKey(newKey)
		VisualPlus:Notify({
			Title = "Клавиша изменена",
			Text = "Теперь: " .. newKey,
			Duration = 3,
		})
	end,
})

local secInfo = tabSettings:AddSection({Name = "Info"})
secInfo:AddButton({
	Text = "Показать текущую клавишу",
	Callback = function()
		VisualPlus:Notify({
			Title = "Текущая клавиша",
			Text = Win:GetToggleKey(),
			Duration = 3,
		})
	end,
})

VisualPlus:Notify({Title = "VisualPlus", Text = "RightShift — открыть/закрыть", Duration = 4})
