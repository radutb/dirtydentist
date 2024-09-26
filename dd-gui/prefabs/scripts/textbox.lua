-- textbox.lua
-- Textinput component for DD-GUI

local M = {}

function M.clearTextbox(self, node)
	-- Clear textbox
	local textNode = gui.get_node(node .. "/text")
	self.textboxData = self.textboxData or {}
	self.textboxData[node] = self.textboxData[node] or {}
	self.textboxData[node].text = self.textboxData[node].text or ""
	self.textboxData[node].text = ""
	gui.set_text(textNode, self.textboxData[node].text)
end

function M.setTextbox(self, node, text)
	local bgNode = gui.get_node(node .. "/bg")
	local textNode = gui.get_node(node .. "/text")
	local hiddenText = gui.get_node(node .. "/hiddentext") -- Hidden text for comparision
	local markerNode = gui.get_node(node .. "/marker")

	-- Check current value
	self.textboxData = self.textboxData or {}
	self.textboxData[node] = self.textboxData[node] or {}
	self.textboxData[node].text = text
	gui.set_text(textNode, self.textboxData[node].text)
	gui.set_text(hiddenText, self.textboxData[node].text)
	
end


function M.textbox(self, action_id, action, node, enabled, tab_to)
	-- Load nodes
	local bgNode = gui.get_node(node .. "/bg")
	local textNode = gui.get_node(node .. "/text")
	local hiddenText = gui.get_node(node .. "/hiddentext") -- Hidden text for comparision
	local markerNode = gui.get_node(node .. "/marker")

	-- Check current value
	self.textboxData = self.textboxData or {}
	self.textboxData[node] = self.textboxData[node] or {}
	self.textboxData[node].text = self.textboxData[node].text or ""
	self.textboxData[node].tab = self.textboxData[node].tab or false
	D.nodes["active"] = D.nodes["active"] or nil
	D.nodes["tab"] = D.nodes["tab"] or false
	gui.set_text(textNode, self.textboxData[node].text)
	
	-- Hovering and enabled
	if gui.pick_node(bgNode, action.x, action.y) and enabled then
		-- Set hover color
		gui.set_color(bgNode, D.colors.hover)
		-- If pressed set active
		if action_id == hash("touch") and action.pressed and gui.pick_node(bgNode, action.x, action.y) and (self.selectedNode == nil or self.selectedNode == node) then
			D.nodes["active"] = node
			D.nodes["tab"] = false
			if D.isMobileDeviceis then
				gui.show_keyboard(gui.KEYBOARD_TYPE_DEFAULT, true)
			end
		end
	elseif not gui.pick_node(bgNode, action.x, action.y) and enabled and self.selectedNode == node then
		-- if not hovered but active
		gui.set_color(bgNode, D.colors.hover)
		-- if preseed utside of field deactivate
		if action_id == hash("touch") and action.pressed then
			D.nodes["active"] = nil
			D.nodes["tab"] = false
			gui.set_color(bgNode, D.colors.active)
			gui.set_enabled(markerNode, false)
			if D.isMobileDeviceis then
				gui.show_keyboard(gui.KEYBOARD_TYPE_DEFAULT, false)
			end
		end
	-- if not active an not hoverd
	elseif not gui.pick_node(bgNode, action.x, action.y) and enabled then
		gui.set_color(bgNode, D.colors.active)
	-- disabled
	elseif not enabled then
		gui.set_color(bgNode, D.colors.inactive)
		if D.nodes["active"] == node then
			D.nodes["active"] = nil
		end
	end

	-- If tab to
	if action_id == hash("tab") and action.pressed and tab_to ~= nil and D.nodes["tab"] == false and D.nodes["active"] == node then
		D.nodes["active"] = tab_to
		gui.set_color(bgNode, D.colors.active)
		gui.set_enabled(markerNode, false)
		D.nodes["tab"] = true
		print("Tab presed")
	end

	if D.nodes["active"] == node then
		print("Node: " .. D.nodes["active"])
		local hiddenText = gui.get_node(node .. "/hiddentext") -- Hidden text for comparison
		local widthmod = window.get_size() / 1280
		gui.set_enabled(markerNode, true)
		if action_id == hash("touch") and action.pressed then
			gui.set_enabled(markerNode, true) -- Enable marker
			gui.set_screen_position(markerNode, vmath.vector3(action.x * widthmod, action.y, 0)) -- Set marker at click position
			self.textboxData[node].makerpos = gui.get_position(markerNode) -- Convert to local pos
			self.textboxData[node].makerpos.y = 0 -- Set y position to 0 to keep in middle of box
			gui.set_position(markerNode, self.textboxData[node].makerpos) -- Update
			gui.set_text(hiddenText, gui.get_text(textNode))
			if utf8.len(gui.get_text(hiddenText)) > 1 then -- If two or more letters allow editing
				while gui.get_text_metrics_from_node(hiddenText).width > self.textboxData[node].makerpos.x do -- Adjust hidden string to fit hiddenstring
					local shortenstring = utf8.sub(gui.get_text(hiddenText), 1, -2)
					gui.set_text(hiddenText, shortenstring)
					if utf8.len(shortenstring) <= 2 then
						break
					end
				end
			end
			self.textboxData[node].makerpos.x = gui.get_text_metrics_from_node(hiddenText).width -- Update marker to be at the end the hiddenstring
			gui.set_position(markerNode, self.textboxData[node].makerpos)
		elseif D.nodes["tab"] then
			gui.set_text(hiddenText, gui.get_text(textNode))
			gui.set_enabled(markerNode, true) -- Enable marker
			self.textboxData[node].makerpos = gui.get_position(markerNode) -- Convert to local pos
			self.textboxData[node].makerpos.y = 0 -- Set y position to 0 to keep in middle of box
			self.textboxData[node].makerpos.x = gui.get_text_metrics_from_node(hiddenText).width -- Update marker to be at the end the hiddenstring
			gui.set_position(markerNode, self.textboxData[node].makerpos)
			D.nodes["tab"] = false -- Reset the tab flag after processing
		end

		-- Input text
		if action_id == hash("text") and gui.get_text_metrics_from_node(textNode).width < (gui.get_size(bgNode).x-25) then
			if utf8.len(gui.get_text(hiddenText)) < utf8.len(gui.get_text(textNode)) then -- Hidden is shorter add text for that point
				local hiddenlength = utf8.len(gui.get_text(hiddenText))
				self.textboxData[node].makerpos = gui.get_position(markerNode)
				local text = gui.get_text(hiddenText)
				text = text .. action.text
				gui.set_text(hiddenText, text)
				text = text .. utf8.sub(gui.get_text(textNode), hiddenlength+1, -1)
				gui.set_text(textNode, text)
				self.textboxData[node].makerpos.x = gui.get_text_metrics_from_node(hiddenText).width
				gui.set_position(markerNode, self.textboxData[node].makerpos)
			elseif utf8.len(gui.get_text(hiddenText)) == utf8.len(gui.get_text(textNode)) then -- If equal add text at the end
				self.textboxData[node].makerpos = gui.get_position(markerNode)
				local text = gui.get_text(hiddenText)
				text = text .. action.text
				gui.set_text(hiddenText, text)
				gui.set_text(textNode, text)
				self.textboxData[node].makerpos.x = gui.get_text_metrics_from_node(hiddenText).width
				gui.set_position(markerNode, self.textboxData[node].makerpos)
			end
		end

		-- Erase using backspace
		if action_id == hash("backspace") and action.repeated then -- Remove letters
			print("backspace")
			if utf8.len(gui.get_text(hiddenText)) < utf8.len(gui.get_text(textNode)) then -- If hidden is shorter remove text from that point
				local hiddenlength = utf8.len(gui.get_text(hiddenText))
				self.textboxData[node].makerpos = gui.get_position(markerNode)
				local text = gui.get_text(hiddenText)
				text = utf8.sub(text, 1, -2)
				gui.set_text(hiddenText, text)
				text = text .. utf8.sub(gui.get_text(textNode), hiddenlength+1, -1)
				gui.set_text(textNode, text)
				self.textboxData[node].makerpos.x = gui.get_text_metrics_from_node(hiddenText).width
				gui.set_position(markerNode, self.textboxData[node].makerpos)
			elseif utf8.len(gui.get_text(hiddenText)) == utf8.len(gui.get_text(textNode)) then -- If equal remove from the end
				local markerPos = gui.get_position(markerNode)
				local text = gui.get_text(hiddenText)
				text = utf8.sub(text, 1, -2)
				gui.set_text(hiddenText, text)
				gui.set_text(textNode, text)
				self.textboxData[node].makerpos.x = gui.get_text_metrics_from_node(hiddenText).width
				gui.set_position(markerNode, self.textboxData[node].makerpos)
			end
		end
		if action_id == hash("delete") and action.repeated then -- Same as above but delete
			if utf8.len(gui.get_text(hiddenText)) < utf8.len(gui.get_text(textNode)) then
				local hiddenlength = utf8.len(gui.get_text(hiddenText))
				self.textboxData[node].makerpos = gui.get_position(markerNode)
				local text = gui.get_text(hiddenText)
				gui.set_text(hiddenText, text)
				text = text .. utf8.sub(gui.get_text(textNode), hiddenlength+2, -1)
				gui.set_text(textNode, text)
				self.textboxData[node].makerpos.x = gui.get_text_metrics_from_node(hiddenText).width
				gui.set_position(markerNode, self.textboxData[node].makerpos)
			elseif utf8.len(gui.get_text(hiddenText)) == utf8.len(gui.get_text(textNode)) then -- If marker at end there is nothing to delete
			print("nothing to delete")
			end
		end
		if action_id == hash("left") and action.pressed and utf8.len(gui.get_text(hiddenText)) > 0 then
			local shortenstring = utf8.sub(gui.get_text(hiddenText), 1, -2)
			gui.set_text(hiddenText, shortenstring)
			self.textboxData[node].makerpos = gui.get_position(markerNode)
			self.textboxData[node].makerpos.x = gui.get_text_metrics_from_node(hiddenText).width
			gui.set_position(markerNode, self.textboxData[node].makerpos)
		elseif action_id == hash("right") and action.pressed and utf8.len(gui.get_text(hiddenText)) < utf8.len(gui.get_text(textNode)) then
			local lengthNew = utf8.len(gui.get_text(hiddenText))
			local lenDiff = utf8.len(gui.get_text(textNode)) - lengthNew
			local shortenstring = utf8.sub(gui.get_text(textNode), 1, -lenDiff)
			gui.set_text(hiddenText, shortenstring)
			self.textboxData[node].makerpos = gui.get_position(markerNode)
			self.textboxData[node].makerpos.x = gui.get_text_metrics_from_node(hiddenText).width
			gui.set_position(markerNode, self.textboxData[node].makerpos)
		end
		self.textboxData[node].text = gui.get_text(textNode)
	end
	return self.textboxData[node].text
end

function M.textboxMultiline(self, action_id, action, node, enabled, tab_to)
	-- Load nodes
	local bgNode = gui.get_node(node .. "/bg")
	local markerNode = gui.get_node(node .. "/marker")
	
	-- Check current value
	self.textboxData = self.textboxData or {}
	self.textboxData[node] = self.textboxData[node] or {}
	self.selectedNode = D.nodes["active"] or nil
	
	-- Hovering and enabled
	if gui.pick_node(bgNode, action.x, action.y) and enabled then
		-- Set hover color
		gui.set_color(bgNode, D.colors.hover)
		-- If pressed set active
		if action_id == hash("touch") and action.pressed and gui.pick_node(bgNode, action.x, action.y) and (self.selectedNode == nil or self.selectedNode == node) then
			D.nodes["active"], self.selectedNode = node, node
			D.nodes["tab"] = false
			if D.isMobileDeviceis then
				gui.show_keyboard(gui.KEYBOARD_TYPE_DEFAULT, true)
			end
		end
	elseif not gui.pick_node(bgNode, action.x, action.y) and enabled and self.selectedNode == node then
		-- if not hovered but active
		gui.set_color(bgNode, D.colors.hover)
		-- if preseed utside of field deactivate
		if action_id == hash("touch") and action.pressed then
			D.nodes["active"], self.selectedNode = nil, nil
			gui.set_color(bgNode, D.colors.active)
			gui.set_enabled(markerNode, false)
			gui.set_enabled(self.textboxData[node].lines[self.textboxData[node].activeline].marker, false)
			if D.isMobileDeviceis then
				gui.show_keyboard(gui.KEYBOARD_TYPE_DEFAULT, false)
			end
		end
		-- if not active an not hoverd
	elseif not gui.pick_node(bgNode, action.x, action.y) and enabled then
		gui.set_color(bgNode, D.colors.active)
		-- disabled
	elseif not enabled then
		gui.set_color(bgNode, D.colors.inactive)
		if self.selectedNode == node then
			D.nodes["active"], self.selectedNode = nil, nil
		end
	end

	-- If tab to
	if action_id == hash("tab") and action.pressed and tab_to ~= nil and D.nodes["tab"] == false and D.nodes["active"] == node then
		D.nodes["active"] = tab_to
		gui.set_color(bgNode, D.colors.active)
		gui.set_enabled(self.textboxData[node].lines[self.textboxData[node].activeline].marker, false)
		D.nodes["tab"] = true
		print("Tab presed")
	end
	

	if D.nodes["active"] == node then
		
		-- Load remaining nodes when active
		local textNode = gui.get_node(node .. "/text")
		local hiddenText = gui.get_node(node .. "/hiddentext") -- Hidden text for comparision
		local markerNode = gui.get_node(node .. "/marker")
		local scrollpos = gui.get_node(node .. "/dragpos")
		local carrier = gui.get_node(node .. "/carrier")
		local innerbox = gui.get_node(node .. "/innerbox")
		local dragpos = gui.get_node(node .. "/dragpos")
		
		self.textboxData[node].text = self.textboxData[node].text or ""
		self.textboxData[node].linecount = self.textboxData[node].linecount or 0
		self.textboxData[node].activeline = self.textboxData[node].activeline or 0
		self.textboxData[node].lines = self.textboxData[node].lines or {}
		self.textboxData[node].sizeFix = self.textboxData[node].sizeFix or false

		-- Fix if size changed
		if not self.textboxData[node].sizeFix then
			local bgSize = gui.get_size(bgNode)
			local textboxSize = gui.get_size(innerbox)
			textboxSize.x = bgSize.x -18 
			gui.set_size(carrier, bgSize)
			gui.set_size(innerbox, textboxSize)
			gui.set_size(hiddenText, textboxSize)
			gui.set_size(textNode, textboxSize)
			bgSize.x = bgSize.x - 7
			gui.set_position(dragpos, bgSize)
			self.textboxData[node].sizeFix = true
		end

		-- Create first line if not created
		if self.textboxData[node].linecount == 0 then
			self.textboxData[node].lines[1] = {text = textNode, hidden = hiddenText, marker = markerNode, innerbox = innerbox, id = 1}
			self.textboxData[node].activeline = 1
			self.textboxData[node].linecount = 1
		end

		-- Check if scroll active
		if #self.textboxData[node].lines*20 > gui.get_size(bgNode).y then
			gui.set_visible(dragpos, true)
		else
			gui.set_visible(dragpos, false)
		end
		local widthmod = window.get_size()/1280

		-- if tabbed to
		if D.nodes["tab"] then
			self.textboxData[node].activeline = #self.textboxData[node].lines
			gui.set_text(self.textboxData[node].lines[self.textboxData[node].activeline].hidden, gui.get_text(self.textboxData[node].lines[self.textboxData[node].activeline].text))
			gui.set_enabled(self.textboxData[node].lines[self.textboxData[node].activeline].marker, true) -- Enable marker
			local markerpos = gui.get_position(self.textboxData[node].lines[self.textboxData[node].activeline].marker)
			markerpos.x = gui.get_text_metrics_from_node(self.textboxData[node].lines[self.textboxData[node].activeline].hidden).width -- Update marker to be at the end the hiddenstring
			gui.set_position(self.textboxData[node].lines[self.textboxData[node].activeline].marker, markerpos)
			gui.set_enabled(self.textboxData[node].lines[self.textboxData[node].activeline].marker, true)
			D.nodes["tab"] = false -- Reset the tab flag after processing
		end

		--Scrolling
		if action_id == hash("wheelup") and gui.pick_node(bgNode, action.x, action.y) then
			for i = 1, #self.textboxData[node].lines do
				local currentPos = gui.get_position(carrier)
				currentPos.y =  D.valuelimit(currentPos.y - D.scrollSpeed/5, 0, gui.get_size(carrier).y-gui.get_size(bgNode).y+10)
				gui.set_position(carrier, currentPos)
			end
			local dragPos = gui.get_position(dragpos)
			local posDelta = -gui.get_position(carrier).y / (gui.get_size(carrier).y - gui.get_size(bgNode).y)
			dragPos.y = D.valuelimit(gui.get_size(bgNode).y * posDelta, -gui.get_size(bgNode).y+10, -5)
			gui.set_position(dragpos, dragPos)
		elseif action_id == hash("wheeldown") and gui.pick_node(bgNode, action.x, action.y) then
			for i = 1, #self.textboxData[node].lines do
				local currentPos = gui.get_position(carrier)
				currentPos.y = D.valuelimit(currentPos.y + D.scrollSpeed/5, 0, gui.get_size(carrier).y-gui.get_size(bgNode).y+10)
				gui.set_position(carrier, currentPos)
			end
			local dragPos = gui.get_position(dragpos)
			local posDelta = -gui.get_position(carrier).y / (gui.get_size(carrier).y - gui.get_size(bgNode).y)
			dragPos.y = D.valuelimit(gui.get_size(bgNode).y * posDelta, -gui.get_size(bgNode).y+10, -5)
			gui.set_position(dragpos, dragPos)
		end

		--Key movment
		local currentline = self.textboxData[node].lines[self.textboxData[node].activeline]
		if action_id == hash("left") and action.pressed and utf8.len(gui.get_text(currentline.hidden)) > 0 then
			local shortenstring = utf8.sub(gui.get_text(currentline.hidden), 1, -2)
			gui.set_text(currentline.hidden, shortenstring)
			local markerPos = gui.get_position(currentline.marker)
			markerPos.x = gui.get_text_metrics_from_node(currentline.hidden).width
			gui.set_position(currentline.marker, markerPos)
		elseif action_id == hash("right") and action.pressed and utf8.len(gui.get_text(currentline.hidden)) < utf8.len(gui.get_text(currentline.text)) then
			local lengthNew = utf8.len(gui.get_text(currentline.hidden))
			local lenDiff = utf8.len(gui.get_text(currentline.text)) - lengthNew
			local shortenstring = utf8.sub(gui.get_text(currentline.text), 1, -lenDiff)
			gui.set_text(currentline.hidden, shortenstring)
			local markerPos = gui.get_position(currentline.marker)
			markerPos.x = gui.get_text_metrics_from_node(currentline.hidden).width
			gui.set_position(currentline.marker, markerPos)
		end
		if action_id == hash("up") and action.pressed and self.textboxData[node].activeline > 1 then
			local lengthstring = utf8.len(gui.get_text(currentline.hidden))
			gui.set_enabled(currentline.marker, false)
			self.textboxData[node].activeline = self.textboxData[node].activeline - 1
			currentline = self.textboxData[node].lines[self.textboxData[node].activeline]
			gui.set_enabled(currentline.marker, true)
			local lenDiff = utf8.len(gui.get_text(currentline.text)) + 1 - lengthstring
			if lenDiff > 0 then
				local shortenstring = utf8.sub(gui.get_text(currentline.text), 1, -lenDiff)
				gui.set_text(currentline.hidden, shortenstring)
			else
				gui.set_text(currentline.hidden, gui.get_text(currentline.text))
			end
			local markerPos = gui.get_position(currentline.marker)
			markerPos.x = gui.get_text_metrics_from_node(currentline.hidden).width
			gui.set_position(currentline.marker, markerPos)

			if gui.get_screen_position(currentline.innerbox).y >= gui.get_screen_position(bgNode).y then
				local carrierpos = gui.get_position(carrier)
				carrierpos.y = carrierpos.y - 20
				gui.set_position(carrier, carrierpos)
				local dragPos = gui.get_position(dragpos)
				local posDelta = -gui.get_position(carrier).y / (gui.get_size(carrier).y - gui.get_size(bgNode).y)
				dragPos.y = D.valuelimit(gui.get_size(bgNode).y * posDelta, -gui.get_size(bgNode).y+15, -5)
				gui.set_position(dragpos, dragPos)
			end

			local dragPos = gui.get_position(dragpos)
			local posDelta = -gui.get_position(carrier).y / (gui.get_size(carrier).y - gui.get_size(bgNode).y)
			dragPos.y = D.valuelimit(gui.get_size(bgNode).y * posDelta, -gui.get_size(bgNode).y+15, -5)
			gui.set_position(dragpos, dragPos)

		elseif action_id == hash("down") and action.pressed and self.textboxData[node].activeline < #self.textboxData[node].lines then
			local lengthstring = utf8.len(gui.get_text(currentline.hidden))
			gui.set_enabled(currentline.marker, false)
			self.textboxData[node].activeline = self.textboxData[node].activeline + 1
			currentline = self.textboxData[node].lines[self.textboxData[node].activeline]
			gui.set_enabled(currentline.marker, true)
			local lenDiff = utf8.len(gui.get_text(currentline.text)) + 1 - lengthstring
			if lenDiff > 0 then
				local shortenstring = utf8.sub(gui.get_text(currentline.text), 1, -lenDiff)
				gui.set_text(currentline.hidden, shortenstring)
			else
				gui.set_text(currentline.hidden, gui.get_text(currentline.text))
			end
			local markerPos = gui.get_position(currentline.marker)
			markerPos.x = gui.get_text_metrics_from_node(currentline.hidden).width
			gui.set_position(currentline.marker, markerPos)

			if gui.get_position(currentline.innerbox).y < -60 then
				local carrierpos = gui.get_position(carrier)
				carrierpos.y = carrierpos.y + 20
				gui.set_position(carrier, carrierpos)
			end

			local dragPos = gui.get_position(dragpos)
			local posDelta = -gui.get_position(carrier).y / (gui.get_size(carrier).y - gui.get_size(bgNode).y)
			dragPos.y = D.valuelimit(gui.get_size(bgNode).y * posDelta, -gui.get_size(bgNode).y+15, -5)
			gui.set_position(dragpos, dragPos)
		end

		-- Touch
		for i = 1, #self.textboxData[node].lines do 
			if action_id == hash("touch") and action.pressed and gui.pick_node(self.textboxData[node].lines[i].innerbox, action.x, action.y) then
				gui.set_text(self.textboxData[node].lines[i].hidden, gui.get_text(self.textboxData[node].lines[i].text))
				self.textboxData[node].activeline = i -- Set active to current
				gui.set_enabled(self.textboxData[node].lines[i].marker, true) -- Enable marker
				gui.set_screen_position(self.textboxData[node].lines[i].marker, vmath.vector3(action.x*widthmod,action.y,0)) -- Set marker at click position
				self.textboxData[node].makerpos = gui.get_position(self.textboxData[node].lines[i].marker) -- Convert to local pos
				self.textboxData[node].makerpos.y = 0
				if utf8.len(gui.get_text(self.textboxData[node].lines[i].hidden)) >= 1 then -- If two or more letters allow editing
					while gui.get_text_metrics_from_node(self.textboxData[node].lines[i].hidden).width > self.textboxData[node].makerpos.x do -- Adjust hidden string to fit hiddenstring
						local shortenstring = utf8.sub(gui.get_text(self.textboxData[node].lines[i].hidden), 1, -2)
						gui.set_text(self.textboxData[node].lines[i].hidden, shortenstring)
						if utf8.len(shortenstring) <= 1 then
							break
						end
					end
				end
				self.textboxData[node].makerpos.x = gui.get_text_metrics_from_node(self.textboxData[node].lines[i].hidden).width -- Update marker to be at the end the hiddenstring
				gui.set_position(self.textboxData[node].lines[i].marker, self.textboxData[node].makerpos)
			elseif action_id == hash("touch") and action.pressed and not gui.pick_node(self.textboxData[node].lines[i].innerbox, action.x, action.y) then
				gui.set_enabled(self.textboxData[node].lines[i].marker, false)
			end
		end

		-- Delete
		if action_id == hash("backspace") and action.repeated then -- Remove one letter
			currentline = self.textboxData[node].lines[self.textboxData[node].activeline]
			if utf8.len(gui.get_text(currentline.hidden)) == 0 and self.textboxData[node].activeline > 1 then -- If higher then first line
				local text = gui.get_text(currentline.text)
				local rowabove = gui.get_text(self.textboxData[node].lines[self.textboxData[node].activeline-1].text)
				text = rowabove .. text
				gui.set_text(self.textboxData[node].lines[self.textboxData[node].activeline - 1].text, text)
				M.deleteLine(node, currentline.id)
				table.remove(self.textboxData[node].lines, self.textboxData[node].activeline)
				self.textboxData[node].activeline = self.textboxData[node].activeline - 1
				M.sortlines(node, self.textboxData[node].lines)
				currentline = self.textboxData[node].lines[self.textboxData[node].activeline]
				gui.set_text(currentline.hidden, rowabove)
				local markerPos = gui.get_position(currentline.marker)
				markerPos.x = gui.get_text_metrics_from_node(currentline.hidden).width
				gui.set_position(currentline.marker, markerPos)
				gui.set_enabled(currentline.marker, true)
				if gui.get_screen_position(currentline.innerbox).y >= gui.get_screen_position(bgNode).y then
					local carrierpos = gui.get_position(carrier)
					carrierpos.y = carrierpos.y - 20
					gui.set_position(carrier, carrierpos)
					local dragPos = gui.get_position(dragpos)
					local posDelta = -gui.get_position(carrier).y / (gui.get_size(carrier).y - gui.get_size(bgNode).y)
					dragPos.y = D.valuelimit(gui.get_size(bgNode).y * posDelta, -gui.get_size(bgNode).y+15, -5)
					gui.set_position(dragpos, dragPos)
				end
			elseif utf8.len(gui.get_text(currentline.hidden)) < utf8.len(gui.get_text(currentline.text)) then -- If hidden is shorter remove text from that point
				local hiddenlength = utf8.len(gui.get_text(currentline.hidden))
				local markerPos = gui.get_position(currentline.marker)
				local text = gui.get_text(currentline.hidden)
				text = utf8.sub(text, 1, -2)
				gui.set_text(currentline.hidden, text)
				text = text .. utf8.sub(gui.get_text(currentline.text), hiddenlength+1, -1)
				gui.set_text(currentline.text, text)
				markerPos.x = gui.get_text_metrics_from_node(currentline.hidden).width
				gui.set_position(currentline.marker, markerPos)
			elseif utf8.len(gui.get_text(currentline.hidden)) == utf8.len(gui.get_text(currentline.text)) then -- If equal remove from the end
				local markerPos = gui.get_position(currentline.marker)
				local text = gui.get_text(currentline.hidden)
				text = utf8.sub(text, 1, -2)
				gui.set_text(currentline.hidden, text)
				gui.set_text(currentline.text, text)
				markerPos.x = gui.get_text_metrics_from_node(currentline.hidden).width
				gui.set_position(currentline.marker, markerPos)
			end
		end
		if action_id == hash("delete") and action.repeated then -- Same as above but delete
			currentline = self.textboxData[node].lines[self.textboxData[node].activeline]
			if utf8.len(gui.get_text(currentline.hidden)) < utf8.len(gui.get_text(currentline.text)) then
				local hiddenlength = utf8.len(gui.get_text(currentline.hidden))
				local markerPos = gui.get_position(currentline.marker)
				local text = gui.get_text(currentline.hidden)
				gui.set_text(currentline.hidden, text)
				text = text .. utf8.sub(gui.get_text(currentline.text), hiddenlength+2, -1)
				gui.set_text(currentline.text, text)
				markerPos.x = gui.get_text_metrics_from_node(hiddenText).width
				gui.set_position(currentline.marker, markerPos)
			elseif utf8.len(gui.get_text(currentline.hidden)) == utf8.len(gui.get_text(currentline.text)) <= #self.textboxData[node].lines then -- If marker at end there is nothing to delete
				print("nothing to delete")
			end
		end

		-- New line
		if action_id == hash("enter") and action.pressed then -- add new line
			currentline = self.textboxData[node].lines[self.textboxData[node].activeline]
			if utf8.len(gui.get_text(currentline.hidden)) < utf8.len(gui.get_text(currentline.text)) then
				local hiddenlength = utf8.len(gui.get_text(currentline.hidden))
				local text = gui.get_text(currentline.hidden)
				local textfornextline = utf8.sub(gui.get_text(currentline.text), hiddenlength+1, -1)
				gui.set_text(currentline.text, text)
				gui.set_enabled(currentline.marker, false)
				self.textboxData[node].linecount = self.textboxData[node].linecount + 1
				self.textboxData[node].activeline = self.textboxData[node].activeline + 1
				table.insert(self.textboxData[node].lines, self.textboxData[node].activeline, M.addline(node, self.textboxData[node].linecount))
				currentline = self.textboxData[node].lines[self.textboxData[node].activeline]
				gui.set_text(currentline.text, textfornextline)
				gui.set_text(currentline.hidden, "")
				M.sortlines(node, self.textboxData[node].lines)
				local markerPos = gui.get_position(currentline.marker)
				markerPos.x = 0
				gui.set_position(currentline.marker, markerPos)
				gui.set_enabled(currentline.marker, true)

				if gui.get_position(currentline.innerbox).y < -(gui.get_size(bgNode).y-20) then
					local carrierpos = gui.get_position(carrier)
					carrierpos.y = carrierpos.y + 20
					gui.set_position(carrier, carrierpos)
				end
				local dragPos = gui.get_position(dragpos)
				local posDelta = -gui.get_position(carrier).y / (gui.get_size(carrier).y - gui.get_size(bgNode).y)
				dragPos.y = D.valuelimit(gui.get_size(bgNode).y * posDelta, -gui.get_size(bgNode).y+15, -5)
				gui.set_position(dragpos, dragPos)
			elseif utf8.len(gui.get_text(currentline.hidden)) == utf8.len(gui.get_text(currentline.text)) and self.textboxData[node].activeline <= #self.textboxData[node].lines then -- If marker at end there is nothing to delete
				gui.set_enabled(currentline.marker, false)
				self.textboxData[node].linecount = self.textboxData[node].linecount + 1
				self.textboxData[node].activeline = self.textboxData[node].activeline + 1
				table.insert(self.textboxData[node].lines, self.textboxData[node].activeline, M.addline(node, self.textboxData[node].linecount))
				currentline = self.textboxData[node].lines[self.textboxData[node].activeline]
				gui.set_text(currentline.hidden, "")
				gui.set_text(currentline.text, "")
				M.sortlines(node, self.textboxData[node].lines)
				local markerPos = gui.get_position(currentline.marker)
				markerPos.x = 0
				gui.set_enabled(currentline.marker, true)
				gui.set_position(currentline.marker, markerPos)

				if gui.get_position(currentline.innerbox).y < -(gui.get_size(bgNode).y-20)  then
					local carrierpos = gui.get_position(carrier)
					carrierpos.y = carrierpos.y + 20
					gui.set_position(carrier, carrierpos)
				end
				local dragPos = gui.get_position(dragpos)
				local posDelta = -gui.get_position(carrier).y / (gui.get_size(carrier).y - gui.get_size(bgNode).y)
				dragPos.y = D.valuelimit(gui.get_size(bgNode).y * posDelta, -gui.get_size(bgNode).y+15, -5)
				gui.set_position(dragpos, dragPos)
			end
		end
		
		local currentline = self.textboxData[node].lines[self.textboxData[node].activeline]
		if action_id == hash("text") and gui.get_text_metrics_from_node(currentline.text).width < (gui.get_size(bgNode).x-25) then
			if utf8.len(gui.get_text(currentline.hidden)) < utf8.len(gui.get_text(currentline.text)) then -- Hidden is shorter add text for that point
				local hiddenlength = utf8.len(gui.get_text(currentline.hidden))
				self.textboxData[node].makerpos = gui.get_position(currentline.marker)
				local text = gui.get_text(currentline.hidden)
				text = text .. action.text
				gui.set_text(currentline.hidden, text)
				text = text .. utf8.sub(gui.get_text(currentline.text), hiddenlength+1, -1)
				gui.set_text(currentline.text, text)
				self.textboxData[node].makerpos.x = gui.get_text_metrics_from_node(currentline.hidden).width
				gui.set_position(currentline.marker, self.textboxData[node].makerpos)
			elseif utf8.len(gui.get_text(currentline.hidden)) == utf8.len(gui.get_text(currentline.text)) then -- If equal add text at the end
				self.textboxData[node].makerpos = gui.get_position(currentline.marker)
				local text = gui.get_text(currentline.text)
				text = text .. action.text
				gui.set_text(currentline.hidden, text)
				gui.set_text(currentline.text, text)
				self.textboxData[node].makerpos.x = gui.get_text_metrics_from_node(currentline.text).width
				gui.set_position(currentline.marker, self.textboxData[node].makerpos)
			end
		elseif action_id == hash("text") and gui.get_text_metrics_from_node(currentline.text).width >= (gui.get_size(bgNode).x-25) then
			gui.set_enabled(currentline.marker, false)
			self.textboxData[node].linecount = self.textboxData[node].linecount + 1
			self.textboxData[node].activeline = self.textboxData[node].activeline + 1
			table.insert(self.textboxData[node].lines, self.textboxData[node].activeline, M.addline(node, self.textboxData[node].activeline))
			gui.set_text(currentline.hidden, "")
			currentline = self.textboxData[node].lines[self.textboxData[node].activeline]
			
			gui.set_text(currentline.text, "")
			M.sortlines(node, self.textboxData[node].lines)
			self.textboxData[node].makerpos = gui.get_position(currentline.marker)
			self.textboxData[node].makerpos.x = 0
			gui.set_enabled(currentline.marker, true)
			gui.set_position(currentline.marker, self.textboxData[node].makerpos)
		end				

	end
	-- Gather return string
	if self.textboxData[node].lines ~= nil then
		local returnstring = ""
		for i = 1, #self.textboxData[node].lines do
			returnstring = returnstring .. gui.get_text(self.textboxData[node].lines[i].text) .. "\n"
		end
		return returnstring
	end
end

function M.deleteLine (node, id)
	local text = gui.get_node(node .. "/text" .. id)
	local hidden = gui.get_node(node .. "/hiddentext" .. id)
	local marker = gui.get_node(node .. "/marker" .. id)
	local innerbox = gui.get_node(node .. "/innerbox" .. id)

	gui.delete_node(text)
	gui.delete_node(hidden)
	gui.delete_node(marker)
	gui.delete_node(innerbox)
end

function M.addline (node, currentline)
	local text = gui.get_node(node .. "/text")
	local hidden = gui.get_node(node .. "/hiddentext")
	local marker = gui.get_node(node .. "/marker")
	local innerbox = gui.get_node(node .. "/innerbox")
	local carrier = gui.get_node(node .. "/carrier")

	local newtext = gui.clone(text)
	local newhidden = gui.clone(hidden)
	local newmarker = gui.clone(marker)
	local newinnerbox = gui.clone(innerbox)

	gui.set_text(newtext, "")
	gui.set_text(newhidden, "")

	gui.set_id(newtext, node .. "/text" .. currentline)
	gui.set_id(newhidden, node .. "/hiddentext" .. currentline)
	gui.set_id(newmarker, node .. "/marker" .. currentline)
	gui.set_id(newinnerbox, node .. "/innerbox" .. currentline)

	gui.set_parent(newtext, newinnerbox, false)
	gui.set_parent(newhidden, newtext, true)
	gui.set_parent(newmarker, newtext, true)
	gui.set_parent(newinnerbox, carrier, true)

	local newPos = vmath.vector3(0, -20*(currentline-1), 0)
	gui.set_position(newinnerbox, newPos)
	local newline = {text = newtext, hidden = newhidden, marker = newmarker, innerbox = newinnerbox, id = currentline} 
	return newline
end

function M.sortlines (node, list)
	for i = 1, #list do
		gui.set_position(list[i].innerbox, vmath.vector3(10,-20 * i,0)) 
	end

	local carrier = gui.get_node(node .. "/carrier")
	local carries_size = gui.get_size(carrier)
	carries_size.y = #list*20
	gui.set_size(carrier, carries_size)
end

return M