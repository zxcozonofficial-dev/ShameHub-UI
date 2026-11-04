-- Luau | Example.client.luau | StarterPlayerScripts LocalScript
local ShameHub = require(game:GetService("ReplicatedStorage"):WaitForChild("ShameHub"))

local window = ShameHub.CreateWindow({
    Title = "ShameHub", Subtitle = "SCRIPT INTERFACE", Footer = "ShameHub / local session",
})

local general = window:AddPage({ Title = "General" })
local interface = general:AddTab("Interface")
local intro = interface:AddSection({ Title = "Welcome", Side = "Full" })
intro:AddParagraph("Your workspace", "Everything you need, in one place. Select a section to get started.")

local left = interface:AddSection({ Title = "General", Side = "Left" })
local enabled = left:AddToggle({ Title = "Enabled", Flag = "Enabled", Default = true,
    Callback = function(value) window:SetStatus("Enabled / " .. tostring(value)) end })
left:AddToggle({ Title = "Notifications", Flag = "Notifications", Default = false })
left:AddToggle({ Title = "Compact mode", Flag = "Compact", Default = true })
left:AddSlider({ Title = "Intensity", Flag = "Intensity", Min = 0, Max = 100, Default = 65, Suffix = "%",
    Callback = function(value) window:SetStatus("Intensity / " .. value .. "%") end })
left:AddParagraph("Preferences", "Changes apply immediately.")

local right = interface:AddSection({ Title = "Appearance", Side = "Right" })
right:AddDropdown({ Title = "Profile", Flag = "Profile", Values = { "Default", "Minimal", "Detailed" }, Default = "Default",
    Callback = function(value) window:SetStatus("Profile / " .. value) end })
right:AddInput({ Title = "Profile name", Flag = "ProfileName", Default = "My profile" })
right:AddKeybind({ Title = "Quick toggle", Flag = "QuickToggle", Default = Enum.KeyCode.F,
    OnPressed = function() enabled:Set(not enabled:Get()) end })
right:AddButton({ Title = "Reset intensity", Callback = function() window.Controls.Intensity:Set(65) end })

local controls = general:AddTab("Controls")
local keyboard = controls:AddSection({ Title = "Keyboard", Side = "Full" })
keyboard:AddParagraph("Shortcuts", "RightShift — show / hide. F — quick toggle (rebindable). Click a keybind to capture a key; Escape cancels.")

local settings = window:AddPage({ Title = "Settings" })
local appearance = settings:AddTab("Appearance")
local colors = appearance:AddSection({ Title = "Menu color", Side = "Left" })
colors:AddColorPicker({ Title = "Accent", Flag = "AccentColor", Default = window.Theme.Accent,
    Callback = function(color) window:SetAccent(color) end })
colors:AddButton({ Title = "Reset color", Callback = function() window.Controls.AccentColor:Set("#FFFFFF") end })
colors:AddToggle({ Title = "Enable transparency", Flag = "MenuTransparencyEnabled", Default = false,
    Callback = function(enabled) window:SetMenuTransparencyEnabled(enabled) end })
colors:AddSlider({ Title = "Strength", Flag = "MenuTransparency", Min = 0, Max = 70, Default = 25, Suffix = "%",
    Callback = function(value) window:SetMenuTransparency(value / 100) end })

local background = appearance:AddSection({ Title = "Background", Side = "Right" })
local source = background:AddInput({ Title = "Image path or URL", Flag = "BackgroundSource", Default = "default", Placeholder = "https://i.pinimg.com/..." })
local loading = false
local function loadBackground(picker)
    if loading then return end
    loading = true
    window:SetStatus(picker and "Choose an image on your PC..." or "Loading background...")
    task.spawn(function()
        local ok, result
        if picker then ok, result = window:PickLocalBackground()
        else ok, result = window:SetBackground(source:Get()) end
        if not window.Dead then
            window:SetStatus(ok and "Background / loaded" or result)
            if ok then source:Set(result, true) end
        end
        loading = false
    end)
end
background:AddButton({ Title = "Apply image", Callback = function() loadBackground(false) end })
background:AddButton({ Title = "Choose local file", Callback = function() loadBackground(true) end })
background:AddSlider({ Title = "Image opacity", Flag = "BackgroundOpacity", Min = 0, Max = 100, Default = 35, Suffix = "%",
    Callback = function(value) window:SetBackgroundOpacity(value / 100) end })
background:AddButton({ Title = "Default background", Callback = function()
    local ok, err = window:SetBackground("default")
    if ok then source:Set("default", true) end
    window:SetStatus(ok and "Background / default" or err)
end })
background:AddButton({ Title = "Remove image", Callback = function()
    window:SetBackground("")
    source:Set("", true)
    window:SetStatus("Background / removed")
end })
background:AddParagraph("Local images", "Run LocalBackground.py once, then choose a PNG, JPG or WebP from your PC.")

local config = settings:AddTab("Config")
local storage = config:AddSection({ Title = "Saved configs", Side = "Left" })
local configName
local configList = storage:AddList({ Title = "Configurations", Height = 140, Values = {}, Callback = function(name)
    if configName and name ~= "" then configName:Set(name, true) end
end })
configName = storage:AddInput({ Title = "Config name", Default = "My config", Placeholder = "Enter a name" })
local actions = config:AddSection({ Title = "Config actions", Side = "Right" })
local autoLabel = actions:AddParagraph("Autoload", "Not set")
local function refreshConfigs(preferred)
    local names, err = window:ListConfigs()
    configList:SetValues(names, preferred)
    autoLabel:Set("Autoload", window:GetAutoloadConfig() or "Not set")
    if err then window:SetStatus(err) end
end
window.ConfigLoaded = function()
    window:SetAccent(window.Controls.AccentColor:GetColor())
    window:SetBackgroundOpacity(window.Controls.BackgroundOpacity:Get() / 100)
    window:SetMenuTransparency(window.Controls.MenuTransparency:Get() / 100)
    window:SetMenuTransparencyEnabled(window.Controls.MenuTransparencyEnabled:Get())
    loadBackground(false)
end
actions:AddButton({ Title = "Save config", Callback = function()
    local ok, result = window:SaveConfig(configName:Get())
    if ok then refreshConfigs(result) end
    window:SetStatus(ok and "Saved / " .. result or result)
end })
actions:AddButton({ Title = "Load config", Callback = function()
    local ok, result = window:LoadConfig(configList:Get())
    window:SetStatus(ok and "Loaded / " .. result or result)
end })
actions:AddButton({ Title = "Set autoload config", Callback = function()
    local ok, result = window:SetAutoloadConfig(configList:Get())
    if ok then refreshConfigs(configList:Get()) end
    window:SetStatus(ok and "Autoload / " .. result or result)
end })
actions:AddButton({ Title = "Refresh list", Callback = function() refreshConfigs() end })
actions:AddParagraph("Storage", window.ConfigFolder)
refreshConfigs()
local autoload = window:GetAutoloadConfig()
if autoload then
    local ok, result = window:LoadAutoloadConfig()
    if ok then refreshConfigs(autoload) end
    window:SetStatus(ok and "Autoloaded / " .. result or result)
end

local about = window:AddPage({ Title = "About" }):AddTab("Library")
about:AddSection({ Title = "ShameHub", Side = "Full" }):AddParagraph("ShameHub", "Geist Sans interface. Custom colors, backgrounds and keyboard controls.")
