-- ddgui.lua
-- Main module for Dirty Dentist GUI

D = {}

-- Require submodules
local button = require "dd-gui.prefabs.scripts.button"
local checkbox = require "dd-gui.prefabs.scripts.checkbox"
local radiobutton = require "dd-gui.prefabs.scripts.radiobutton"
local textbox = require "dd-gui.prefabs.scripts.textbox"
local slider = require "dd-gui.prefabs.scripts.slider"
local combobox = require "dd-gui.prefabs.scripts.combobox"

-- Add more requires as you create additional submodules (e.g., combobox, radio, etc.)

-- Expose input methods
D.button = button.button
D.togglebutton = button.togglebutton
D.checkbox = checkbox.checkbox
D.checkboxSelectall = checkbox.checkboxSelectall
D.radiobutton = radiobutton.radiobutton
D.textbox = textbox.textbox
D.textboxMultiline = textbox.textboxMultiline
D.slider = slider.slider
D.combobox = combobox.combobox
D.auto_suggestbox = combobox.auto_suggestbox

-- Expose additional functions
D.clearTextbox = textbox.clearTextbox
D.initializeCombo = combobox.initialize
D.clearCheckbox = checkbox.clearCheckbox
D.setValueAutobox = combobox.setValueAutobox
D.resetSlider = slider.resetSlider
D.setValueCombobox = combobox.setValueCombobox
D.toggleActive = button.toggleActive

-- Shared variables (if needed)
D.colors = {
	active		= vmath.vector4(1, 1, 1, 1),
	hover		= vmath.vector4(0.9, 0.9, 0.9, 1),
	select		= vmath.vector4(0.8, 0.8, 0.8, 1),
	inactive	= vmath.vector4(0.3, 0.3, 0.3, 0.5),
	accent		= vmath.vector4(0.17, 0.50, 0.79, 1),
	accenthover	= vmath.vector4(0.17, 0.50, 0.79, 0.8),
	green		= vmath.vector4(0.1, 1, 0.1, 1),
	red			= vmath.vector4(1, 0.1, 0.1, 1),
	black		= vmath.vector4(0, 0, 0,  1),
	white		= vmath.vector4(1, 1, 1,  1)
}

D.isMobileDevice = false
D.scrollSpeed = 18
D.textMagnification = 0.75
D.nodes = {}

-- Localization strings
D.no_entries = "No entries found"
D.select_a_value = "Select a value"

-- Function to set localization strings
function D.set_localization_strings(no_entries_str, select_value_str)
	D.no_entries = no_entries_str
	D.select_a_value = select_value_str
end

-- Function to check device type (if needed)
function D.check_device(self)
	local info = sys.get_sys_info()
	local user_agent = info.user_agent or ""

	if info.system_name == "HTML5" then
		local user_agent_lower = user_agent:lower()
		if user_agent_lower:find("android") or user_agent_lower:find("iphone") or user_agent_lower:find("ipad") then
			D.isMobileDevice = true
		end
	elseif info.system_name == "Android" or info.system_name == "iPhone OS" then
		D.isMobileDevice = true
	end
	pprint(info)
end

-- Function that limits input values
function D.valuelimit(v, min, max)
	if v < min then
		return min
	elseif v > max then
		return max
	end
	return v
end


return D