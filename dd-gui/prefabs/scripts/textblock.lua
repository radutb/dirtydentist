-- textblock.lua
-- textblock component for DD-GUI

local M = {}


function M.setTextblock(self, node, text)
	local bgNode = gui.get_node(node .. "/bg")
	local textNode = gui.get_node(node .. "/text")
	local carrier = gui.get_node(node .. "/carrier")
	local dragpos = gui.get_node(node .. "/dragpos")

	-- Check current value
	self.textboxData = self.textboxData or {}
	self.textboxData[node] = self.textboxData[node] or {}
	self.textboxData[node].text = self.textboxData[node].text or ""
	self.textboxData[node].init = false
	self.textboxData[node].marker = self.textboxData[node].marker or false
	self.textboxData[node].scroll = self.textboxData[node].scroll or {}

	gui.set_text(textNode, text)
	self.textboxData[node].text = text
	
	if not self.textboxData[node].init then
		local textMetrics = gui.get_text_metrics_from_node(text)
		gui.set_position(dragpos, vmath.vector3(gui.get_size(bgNode).x-8, 10, 0))
		gui.set_size(text, vmath.vector3(gui.get_size(bgNode).x, textMetrics.height+20, 0))
		gui.set_size(carrier, vmath.vector3(gui.get_size(bgNode).x, textMetrics.height+20, 0))
		if textMetrics.height > gui.get_size(bgNode).y then
			self.textboxData[node].marker = true
		end
		-- Check if marker should bw shown
		if self.textboxData[node].marker then
			gui.set_enabled(dragpos, true)
		else
			gui.set_enabled(dragpos, false)
		end
		self.textboxData[node].init = true
	end
end

function M.textBlock(self, action_id, action, node, enabled)
	-- Load nodes
	local bgNode = gui.get_node(node .. "/bg")
	local carrier = gui.get_node(node .. "/carrier")
	local dragpos = gui.get_node(node .. "/dragpos")
	local text = gui.get_node(node .. "/text")
	
	-- Check current value
	self.textboxData = self.textboxData or {}
	self.textboxData[node] = self.textboxData[node] or {}
	self.textboxData[node].text = self.textboxData[node].text or text
	self.textboxData[node].init = self.textboxData[node].init or false
	self.textboxData[node].marker = self.textboxData[node].marker or false
	self.textboxData[node].scroll = self.textboxData[node].scroll or {}	
	self.textboxData[node].active = self.textboxData[node].active or enabled	 

	-- Hovering and enabled
	if gui.pick_node(bgNode, action.x, action.y) and self.textboxData[node].active and D.nodes["active"] == nil then
		gui.set_color(bgNode, D.colors.hover)
		D.nodes["active"] = node
	elseif not self.textboxData[node].scroll.active and not gui.pick_node(bgNode, action.x, action.y) and self.textboxData[node].active and D.nodes["active"] == node then
		gui.set_color(bgNode, D.colors.active)
		D.nodes["active"] = nil
	elseif not self.textboxData[node].active then
		gui.set_color(bgNode, D.colors.inactive)
	end
	-- Init if not done yet
	if not self.textboxData[node].init then
		local textMetrics = gui.get_text_metrics_from_node(text)
		gui.set_position(dragpos, vmath.vector3(gui.get_size(bgNode).x-8, 10, 0))
		gui.set_size(text, vmath.vector3(gui.get_size(bgNode).x, textMetrics.height+20, 0))
		gui.set_size(carrier, vmath.vector3(gui.get_size(bgNode).x, textMetrics.height+20, 0))
		gui.set_size(text, vmath.vector3(textMetrics.width, textMetrics.height+20, 0))
		gui.set_size(carrier, vmath.vector3(textMetrics.width, textMetrics.height+20, 0))
		if textMetrics.height > gui.get_size(bgNode).y then
			self.textboxData[node].marker = true
		end
		self.textboxData[node].init = true
	end
	
	if D.nodes["active"] == node then
		
		-- Check if marker should bw shown
		if self.textboxData[node].marker then
			gui.set_enabled(dragpos, true)
			-- Handle mouse input
			if action_id == hash("touch") and action.pressed then
				self.textboxData[node].scroll.active = true
				self.textboxData[node].scroll.pos = vmath.vector3(action.x, action.y, 0)
			elseif action_id == hash("touch") and action.released then
				self.textboxData[node].scroll.active = false
				self.textboxData[node].scroll.pos = vmath.vector3(action.x, action.y, 0)
				-- Reset if outside node
				if not gui.pick_node(bgNode, action.x, action.y) then
					gui.set_color(bgNode, D.colors.active)
					D.nodes["active"] = nil
				end
			end
			--Scrolling
			if self.textboxData[node].scroll.active then
				local currentPos = gui.get_position(carrier)
				self.textboxData[node].scroll.delta = self.textboxData[node].scroll.pos - vmath.vector3(action.x, action.y, 0)
				self.textboxData[node].scroll.pos = vmath.vector3(action.x, action.y, 0)
				currentPos.y =  D.valuelimit(currentPos.y - self.textboxData[node].scroll.delta.y, 0, gui.get_size(carrier).y-gui.get_size(bgNode).y)
				gui.set_position(carrier, currentPos)
				local dragPos = gui.get_position(dragpos)
				local posDelta = -gui.get_position(carrier).y / (gui.get_size(carrier).y - gui.get_size(bgNode).y)
				dragPos.y = D.valuelimit(gui.get_size(bgNode).y * posDelta, -gui.get_size(bgNode).y+15, -15)
				gui.set_position(dragpos, dragPos)
			elseif action_id == hash("wheelup") and gui.pick_node(bgNode, action.x, action.y) then
				local currentPos = gui.get_position(carrier)
				currentPos.y =  D.valuelimit(currentPos.y - D.scrollSpeed/3, 0, gui.get_size(carrier).y-gui.get_size(bgNode).y)
				gui.set_position(carrier, currentPos)
				local dragPos = gui.get_position(dragpos)
				local posDelta = -gui.get_position(carrier).y / (gui.get_size(carrier).y - gui.get_size(bgNode).y)
				dragPos.y = D.valuelimit(gui.get_size(bgNode).y * posDelta, -gui.get_size(bgNode).y+15, -15)
				gui.set_position(dragpos, dragPos)
			elseif action_id == hash("wheeldown") and gui.pick_node(bgNode, action.x, action.y) then
				local currentPos = gui.get_position(carrier)
				currentPos.y = D.valuelimit(currentPos.y + D.scrollSpeed/3, 0, gui.get_size(carrier).y-gui.get_size(bgNode).y)
				gui.set_position(carrier, currentPos)
				local dragPos = gui.get_position(dragpos)
				local posDelta = -gui.get_position(carrier).y / (gui.get_size(carrier).y - gui.get_size(bgNode).y-10)
				dragPos.y = D.valuelimit(gui.get_size(bgNode).y * posDelta, -gui.get_size(bgNode).y+15, -15)
				gui.set_position(dragpos, dragPos)
			end
		else
			gui.set_enabled(dragpos, false)
		end	
	end
end

return M