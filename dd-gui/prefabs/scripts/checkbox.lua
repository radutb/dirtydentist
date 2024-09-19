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
	

function M.checkbox(self, action_id, action, node, enabled, text)
	-- Load nodes
	local bgNode = gui.get_node(node .. "/bg")
	local checkNode = gui.get_node(node .. "/check")
	local txtBox = gui.get_node(node .. "/txtbox")
	local txtNode = gui.get_node(node .. "/txt")

	-- Check current value
	self.checkbox = self.checkbox or {}
	self.selectedNode = D.nodes["active"] or nil

	if enabled then
		if self.checkbox[node] then
			gui.set_color(bgNode, D.colors.active)
		else
			gui.set_color(bgNode, D.colors.accent)
		end
	end
	
	-- Check if hovering above
	if gui.pick_node(bgNode, action.x, action.y) and enabled and (self.selectedNode == nil or self.selectedNode == node) then
		-- Set as active node
		D.nodes["active"] = node
		if self.checkbox[node] then
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
		if action_id == hash("touch") and action.pressed and self.checkbox[node] then
			self.checkbox[node] = false
			gui.set_enabled(checkNode, false)
			gui.set_color(bgNode, D.colors.hover)
		elseif action_id == hash("touch") and action.pressed and self.checkbox[node] ~= true then
			self.checkbox[node] = true
			gui.set_enabled(checkNode, true)
			gui.set_color(bgNode, D.colors.accenthover)
		end
	elseif enabled and not gui.pick_node(bgNode, action.x, action.y) and self.selectedNode == node then
		gui.set_enabled(txtBox, false)
		gui.set_color(bgNode, D.colors.active)
		D.nodes["active"] = nil
		if self.checkbox[node] then
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
	return self.checkbox[node]
end

function M.checkboxSelectall(self, action_id, action, node, othernodes, enabled, text)
	-- Load nodes
	local bgNode = gui.get_node(node .. "/bg")
	local checkNode = gui.get_node(node .. "/check")
	local txtBox = gui.get_node(node .. "/txtbox")
	local txtNode = gui.get_node(node .. "/txt")

	-- Check current value
	self.checkbox = self.checkbox or {}
	self.selectedNode = D.nodes["active"] or nil

	if enabled then
		-- Check other checkboxes
		local numberActive = 0
		for i = 0, #othernodes do
			if self.checkbox[othernodes[i]] then
				numberActive = numberActive + 1
			end
		end
		if numberActive > 0 and numberActive < #othernodes then
			gui.set_enabled(checkNode, true)
			gui.play_flipbook(checkNode, "line")
			self.checkbox[node] = true
			gui.set_color(bgNode, D.colors.accent)
		elseif numberActive == #othernodes then
			gui.set_enabled(checkNode, true)
			gui.play_flipbook(checkNode, "check")
			self.checkbox[node] = true
			gui.set_color(bgNode, D.colors.accent)
		else
			gui.set_enabled(checkNode, false)
			self.checkbox[node] = false
			gui.set_color(bgNode, D.colors.active)
		end
		
		-- Check if hovering above
		if gui.pick_node(bgNode, action.x, action.y) and (self.selectedNode == nil or self.selectedNode == node) then
			-- Set as active node
			D.nodes["active"] = node
			if self.checkbox[node] then
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
			if action_id == hash("touch") and action.pressed and self.checkbox[node] then
				self.checkbox[node] = false
				gui.set_enabled(checkNode, false)
				gui.set_color(bgNode, D.colors.hover)
				-- Deactivate all other
				for i = 1, #othernodes do
					local otherBgNode = gui.get_node(othernodes[i] .. "/bg")
					local otherCheckNode = gui.get_node(othernodes[i] .. "/check")
					self.checkbox[othernodes[i]] = false
					gui.set_enabled(otherCheckNode, false)
					gui.set_color(otherBgNode, D.colors.active)
				end
			elseif action_id == hash("touch") and action.pressed and self.checkbox[node] ~= true then
				self.checkbox[node] = true
				gui.set_enabled(checkNode, true)
				gui.set_color(bgNode, D.colors.accenthover)
				gui.play_flipbook(checkNode, "check")
				for i = 1, #othernodes do
					local otherBgNode = gui.get_node(othernodes[i] .. "/bg")
					local otherCheckNode = gui.get_node(othernodes[i] .. "/check")
					self.checkbox[othernodes[i]] = true
					gui.set_enabled(otherCheckNode, true)
					gui.set_color(otherBgNode, D.colors.accent)
				end
			end
		elseif enabled and not gui.pick_node(bgNode, action.x, action.y) and self.selectedNode == node then
			gui.set_enabled(txtBox, false)
			gui.set_color(bgNode, D.colors.active)
			D.nodes["active"] = nil
			if self.checkbox[node] then
				gui.set_color(bgNode, D.colors.accent)
			else
				gui.set_color(bgNode, D.colors.active)
			end
		end
	elseif enabled == false then
		gui.set_color(bgNode, D.colors.inactive)
		if self.selectedNode == node then
			D.nodes["active"] = nil
		end
		gui.set_enabled(txtBox, false)
	end
	--return value
	return self.checkbox[node]
end

return M