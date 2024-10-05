-- textblock.lua
-- Textblock component for DD-GUI

local M = {}

local function initTextblock(self, node)
	local dragpos = gui.get_node(node .. "/dragpos")
	local carrier = gui.get_node(node .. "/carrier")
	local textNode = gui.get_node(node .. "/text")
	local bgNode = gui.get_node(node .. "/bg")
	
	-- Init if not done yet
	if not self.textboxData[node].init then
		-- Check if active
		if self.textboxData[node].active then
			gui.set_color(bgNode, D.colors.active)
		elseif not self.textboxData[node].active then
			gui.set_color(bgNode, D.colors.inactive)
		end
		-- Atelast same size as bg
		gui.set_position(carrier, vmath.vector3(0,0,0))
		gui.set_size(textNode, vmath.vector3(gui.get_size(bgNode).x-20, gui.get_size(bgNode).y, 0))	
		local textMetrics = gui.get_text_metrics_from_node(textNode)
		gui.set_position(dragpos, vmath.vector3(gui.get_size(bgNode).x-8, 10, 0))
		--Adjust text and carrier blocks to fit all text
		gui.set_size(textNode, vmath.vector3(gui.get_size(bgNode).x-20, textMetrics.height+20, 0))
		gui.set_size(carrier, vmath.vector3(gui.get_size(bgNode).x-20, textMetrics.height+20, 0))
		textMetrics = gui.get_text_metrics_from_node(textNode)
		if textMetrics.height > gui.get_size(bgNode).y then
			self.textboxData[node].marker = true
			gui.set_enabled(dragpos, true)
			local dragPos = gui.get_position(dragpos)
			dragPos.y = -15
			gui.set_position(dragpos, dragPos)
		else
			self.textboxData[node].marker = false
			gui.set_enabled(dragpos, false)
		end
		self.textboxData[node].init = true
	end
end

local function scrollTextblock(dragpos, carrier, bgNode, scrollSpeed)
	if scrollSpeed ~= nil then
		local currentPos = gui.get_position(carrier)
		currentPos.y =  D.valuelimit(currentPos.y + scrollSpeed/3, 0, gui.get_size(carrier).y-gui.get_size(bgNode).y)
		gui.set_position(carrier, currentPos)
	end
	local dragPos = gui.get_position(dragpos)
	local posDelta = -gui.get_position(carrier).y / (gui.get_size(carrier).y - gui.get_size(bgNode).y)
	dragPos.y = D.valuelimit(gui.get_size(bgNode).y * posDelta, -gui.get_size(bgNode).y+15, -15)
	gui.set_position(dragpos, dragPos)
end

function M.setTextblock(self, node, text)
	local textNode = gui.get_node(node .. "/text")
	-- Check current value
	self.textboxData = self.textboxData or {}
	self.textboxData[node] = self.textboxData[node] or {}
	self.textboxData[node].text = self.textboxData[node].text or ""
	self.textboxData[node].init = false
	self.textboxData[node].marker = self.textboxData[node].marker or false
	self.textboxData[node].scroll = self.textboxData[node].scroll or {}
	self.textboxData[node].text = text
	gui.set_text(textNode, text)
	initTextblock(self, node)
end

function M.textBlock(self, action_id, action, node, enabled)
	-- Load nodes
	local bgNode = gui.get_node(node .. "/bg")
	local carrier = gui.get_node(node .. "/carrier")
	local dragpos = gui.get_node(node .. "/dragpos")

	-- Check current value
	self.textboxData = self.textboxData or {}
	self.textboxData[node] = self.textboxData[node] or {}
	self.textboxData[node].text = self.textboxData[node].text or ""
	self.textboxData[node].init = self.textboxData[node].init or false
	self.textboxData[node].marker = self.textboxData[node].marker or false
	self.textboxData[node].scroll = self.textboxData[node].scroll or {}	
	self.textboxData[node].active = enabled 

	-- Hovering and enabled
	if gui.pick_node(bgNode, action.x, action.y) and self.textboxData[node].active and D.nodes["active"] == nil then
		gui.set_color(bgNode, D.colors.active)
		D.nodes["active"] = node
	elseif not self.textboxData[node].scroll.active and not gui.pick_node(bgNode, action.x, action.y) and self.textboxData[node].active and D.nodes["active"] == node then
		gui.set_color(bgNode, D.colors.active)
		D.nodes["active"] = nil
	elseif not self.textboxData[node].active then
		gui.set_color(bgNode, D.colors.inactive)
	else
		gui.set_color(bgNode, D.colors.active)
	end
	initTextblock(self, node)

	if D.nodes["active"] == node then
		-- Handle mouse input
		if action_id == hash("touch") and action.pressed then
			self.textboxData[node].scroll.active = true
			self.textboxData[node].scroll.pos = vmath.vector3(action.x, action.y, 0)
		elseif action_id == hash("touch") and action.released then
			self.textboxData[node].scroll.active = false
			-- Reset if outside node
			if not gui.pick_node(bgNode, action.x, action.y) then
				gui.set_color(bgNode, D.colors.active)
				D.nodes["active"] = nil
			end
		end
		--Scrolling
		if  (gui.get_size(carrier).y - gui.get_size(bgNode).y) > 0 then 
			if self.textboxData[node].scroll.active then
				local currentPos = gui.get_position(carrier)
				self.textboxData[node].scroll.delta = self.textboxData[node].scroll.pos - vmath.vector3(action.x, action.y, 0)
				self.textboxData[node].scroll.pos = vmath.vector3(action.x, action.y, 0)
				currentPos.y =  D.valuelimit(currentPos.y - self.textboxData[node].scroll.delta.y, 0, gui.get_size(carrier).y-gui.get_size(bgNode).y)
				gui.set_position(carrier, currentPos)
				scrollTextblock(dragpos, carrier, bgNode, nil)
			elseif action_id == hash("wheelup") and gui.pick_node(bgNode, action.x, action.y) then
				scrollTextblock(dragpos, carrier, bgNode, -D.scrollSpeed)
			elseif action_id == hash("wheeldown") and gui.pick_node(bgNode, action.x, action.y) then
				scrollTextblock(dragpos, carrier, bgNode, D.scrollSpeed)
			end
		end
	end
end

return M