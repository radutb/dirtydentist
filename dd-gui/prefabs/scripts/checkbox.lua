-- checkbox.lua
-- Checkbox component for DD-GUI

local M = {}

function M.clearCheckbox (self, node)
	local bgNode = gui.get_node(node .. "/bg")
	local checkNode = gui.get_node(node .. "/check")
	local txtBox = gui.get_node(node .. "/txtbox")

	self.checkbox = self.checkbox or {}
	self.checkbox[node] = false
	gui.set_enabled(checkNode, false)
	gui.set_color(bgNode, D.colors.active)
	gui.set_enabled(txtBox, false)
end


function M.checkbox(self, action_id, action, node, enabled, standard_value, text)
	-- Load nodes
	local bgNode = gui.get_node(node .. "/bg")
	local checkNode = gui.get_node(node .. "/check")
	local txtBox = gui.get_node(node .. "/txtbox")
	local txtNode = gui.get_node(node .. "/txt")

	-- Check current value
	self.checkbox = self.checkbox or {}
	self.checkbox[node] = self.checkbox[node] or {}
	self.checkbox[node].init = self.checkbox[node].init or false
	self.checkbox[node].value = self.checkbox[node].value or false
	self.checkbox[node].enabled = enabled 
	D.nodes["active"] = D.nodes["active"] or nil

	if not self.checkbox[node].init and enabled then
		-- Set standrad value
		if standard_value ~= nil then
			self.checkbox[node].value = standard_value
		end
		-- Update
		if self.checkbox[node].value then
			gui.set_enabled(checkNode, true)
			gui.set_color(bgNode, D.colors.accent)
		else
			gui.set_enabled(checkNode, false)
			gui.set_color(bgNode, D.colors.active)
		end
		self.checkbox[node].init = true	
	elseif enabled then
		if self.checkbox[node].value then
			gui.set_color(bgNode, D.colors.accent)
			gui.set_enabled(checkNode, true)
		else
			gui.set_color(bgNode, D.colors.active)
			gui.set_enabled(checkNode, false)
		end
	else
		gui.set_enabled(checkNode, false)
		gui.set_color(bgNode, D.colors.inactive)
	end

	-- Check if hovering above
	if gui.pick_node(bgNode, action.x, action.y) and enabled and (D.nodes["active"]== nil or D.nodes["active"] == node) then
		-- Set as active node
		D.nodes["active"] = node
		if self.checkbox[node].value then
			gui.set_color(bgNode, D.colors.accenthover)
		else
			gui.set_color(bgNode, D.colors.hover)
		end
		-- Set text to explination box and adjust size
		if text ~= nil then
			gui.set_text(txtNode, text)
			local text_width = gui.get_text_metrics_from_node(txtNode).width
			local current_size = gui.get_size(txtBox)
			gui.set_size(txtBox, vmath.vector3(text_width + 20, current_size.y, current_size.z))
			gui.set_enabled(txtBox, true)
		end
		-- When pressed check if to be activated or deactivated
		if action_id == hash("touch") and action.pressed and self.checkbox[node].value then
			self.checkbox[node].value = false
			gui.set_enabled(checkNode, false)
			gui.set_color(bgNode, D.colors.hover)
		elseif action_id == hash("touch") and action.pressed and self.checkbox[node].value ~= true then
			self.checkbox[node].value = true
			gui.set_enabled(checkNode, true)
			gui.set_color(bgNode, D.colors.accenthover)
		end
	elseif enabled and not gui.pick_node(bgNode, action.x, action.y) and D.nodes["active"] == node then
		gui.set_enabled(txtBox, false)
		gui.set_color(bgNode, D.colors.active)
		D.nodes["active"] = nil
		if self.checkbox[node].value then
			gui.set_color(bgNode, D.colors.accent)
		else
			gui.set_color(bgNode, D.colors.active)
		end
	elseif enabled == false then
		gui.set_color(bgNode, D.colors.inactive)
		if self.selectedNode == node then
			D.nodes["active"] = nil
		end
		gui.set_enabled(txtBox, false)
	end
	--return value
	return self.checkbox[node].value
end

function M.checkboxSelectall(self, action_id, action, node, othernodes, enabled, standard_value, text)
	-- Load nodes
	local bgNode = gui.get_node(node .. "/bg")
	local checkNode = gui.get_node(node .. "/check")
	local txtBox = gui.get_node(node .. "/txtbox")
	local txtNode = gui.get_node(node .. "/txt")

	-- Check current value
	self.checkbox = self.checkbox or {}
	self.checkbox[node] = self.checkbox[node] or {}
	self.checkbox[node].init = self.checkbox[node].init or false
	self.checkbox[node].value = self.checkbox[node].value or false
	self.checkbox[node].enabled = enabled
	D.nodes["active"] = D.nodes["active"] or nil

	-- Initalize
	if not self.checkbox[node].init and enabled then
		-- Set standrad value
		if standard_value ~= nil then
			self.checkbox[node].value = standard_value
		end
		-- Update
		if self.checkbox[node].value then
			gui.set_enabled(checkNode, true)
			gui.set_color(bgNode, D.colors.accent)
			for i = 1, #othernodes do
				if self.checkbox[othernodes[i]].enabled then
					local otherBgNode = gui.get_node(othernodes[i] .. "/bg")
					local otherCheckNode = gui.get_node(othernodes[i] .. "/check")
					self.checkbox[othernodes[i]].value = true
					gui.set_enabled(otherCheckNode, true)
					gui.set_color(otherBgNode, D.colors.accent)
				else
					local otherBgNode = gui.get_node(othernodes[i] .. "/bg")
					local otherCheckNode = gui.get_node(othernodes[i] .. "/check")
					self.checkbox[othernodes[i]].value = false
					gui.set_enabled(otherCheckNode, false)
					gui.set_color(otherBgNode, D.colors.inactive)
				end
			end
		else
			gui.set_enabled(checkNode, false)
			gui.set_color(bgNode, D.colors.inactive)
		end
		self.checkbox[node].init = true
	end

	-- Run input
	if enabled and self.checkbox[node].init then
		-- Check other checkboxes
		local numberActive = 0
		for i = 1, #othernodes do
			if self.checkbox[othernodes[i]].value then
				numberActive = numberActive + 1
			end
		end
		if numberActive > 0 and numberActive < #othernodes then
			gui.set_enabled(checkNode, true)
			gui.play_flipbook(checkNode, "line")
			self.checkbox[node].value = true
			gui.set_color(bgNode, D.colors.accent)
		elseif numberActive == #othernodes then
			gui.set_enabled(checkNode, true)
			gui.play_flipbook(checkNode, "check")
			self.checkbox[node].value = true
			gui.set_color(bgNode, D.colors.accent)
		else
			gui.set_enabled(checkNode, false)
			self.checkbox[node].value = false
			gui.set_color(bgNode, D.colors.active)
		end
	end

	-- Check if hovering above
	if gui.pick_node(bgNode, action.x, action.y) and (D.nodes["active"]  == nil or D.nodes["active"]  == node) and enabled then
		-- Set as active node
		D.nodes["active"] = node
		if self.checkbox[node].value then
			gui.set_color(bgNode, D.colors.accenthover)
		else
			gui.set_color(bgNode, D.colors.hover)
		end

		-- Set text to explination box and adjust size
		if text ~= nil then
			gui.set_text(txtNode, text)
			local text_width = gui.get_text_metrics_from_node(txtNode).width
			local current_size = gui.get_size(txtBox)
			gui.set_size(txtBox, vmath.vector3(text_width + 20, current_size.y, current_size.z))
			gui.set_enabled(txtBox, true)
		end

		-- When pressed check if to be activated or deactivated
		if action_id == hash("touch") and action.pressed and self.checkbox[node].value then
			self.checkbox[node].value = false
			gui.set_enabled(checkNode, false)
			gui.set_color(bgNode, D.colors.hover)
			-- Deactivate all other
			for i = 1, #othernodes do
				local otherBgNode = gui.get_node(othernodes[i] .. "/bg")
				local otherCheckNode = gui.get_node(othernodes[i] .. "/check")
				self.checkbox[othernodes[i]].value = false
				gui.set_enabled(otherCheckNode, false)
				gui.set_color(otherBgNode, D.colors.active)
			end
		elseif action_id == hash("touch") and action.pressed and self.checkbox[node].value ~= true then
			self.checkbox[node].value = true
			gui.set_enabled(checkNode, true)
			gui.set_color(bgNode, D.colors.accenthover)
			gui.play_flipbook(checkNode, "check")
			for i = 1, #othernodes do
				local otherBgNode = gui.get_node(othernodes[i] .. "/bg")
				local otherCheckNode = gui.get_node(othernodes[i] .. "/check")
				self.checkbox[othernodes[i]].value = true
				gui.set_enabled(otherCheckNode, true)
				gui.set_color(otherBgNode, D.colors.accent)
			end
		end
	elseif enabled and not gui.pick_node(bgNode, action.x, action.y) and D.nodes["active"] == node then
		gui.set_enabled(txtBox, false)
		gui.set_color(bgNode, D.colors.active)
		D.nodes["active"] = nil
		if self.checkbox[node].value then
			gui.set_color(bgNode, D.colors.accent)
		else
			gui.set_color(bgNode, D.colors.active)
		end
	elseif enabled == false then
		gui.set_color(bgNode, D.colors.inactive)
		if D.nodes["active"]  == node then
			D.nodes["active"] = nil
		end
		gui.set_enabled(txtBox, false)
	end
	--return value
	return self.checkbox[node].value
end

return M