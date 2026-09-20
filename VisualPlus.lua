local VisualPlus = loadstring(game:HttpGet("https://raw.githubusercontent.com/ТВОЙ_НИК/visualplus/main/VisualPlus.lua"))()

local Win = VisualPlus:CreateWindow({
	Title = "VisualPlus",
	Subtitle = "v1.0",
	Size = UDim2.fromOffset(720, 460),
})

local tabMain = Win:AddTab({Name = "Main"})
local tabVisual = Win:AddTab({Name = "Visual"})
local tabSettings = Win:AddTab({Name = "Settings"})

-- MAIN
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

-- VISUAL
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

-- SETTINGS
local sec3 = tabSettings:AddSection({Name = "Keybinds"})

sec3:AddKeyPicker("Teleport", {
	Default = "X",
	Callback = function()
		VisualPlus:Notify({Title = "TP", Text = "Клавиша нажата", Duration = 2})
	end,
})

VisualPlus:Notify({Title = "VisualPlus", Text = "Загружено", Duration = 4})
