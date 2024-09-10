# DirtyDentist-GUI (DD-GUI)
A basic GUI library for Defold developed for educational softwares. It covers the essentials including; drop-downs, comboboxes, simple buttons, checkboxes, radio buttons, text fields and text boxes. Notably, the text components allow for mid-string editing and navigation using arrow keys.

[HTML5 Example](https://skogsheden.se/dirtydentist)

![Screenshot](/screenshot.png)

## Implementation

Use included prefabs and name after hearts content. Implement in GUI script under function on_input(self, action_id, action) as described below if not else specified. 

### Buttons
Simple button:

*Function returns true or false*
```
button_touch(self, action_id, action, "NodeName", active(boolean))
```
Checkbox:

*Function returns true or false*
```
checkbox(self, action_id, action, "NodeName", active(boolean))
```
Radiobutton:

*Function which button that is selected*
```
radio(self, action_id, action, group(int), {"NodeName1", "NodeName2", "NodeName3"}, active(boolean))
```

### Slider
*Function returns value between -1 and 1*

```
slider(self, action_id, action, "NodeName")
```

### Dropdowns

*Dropdowns need to be initialised*
```
function init(self)
	ListName = {
		"Luke Skywalker",
		"Obi-Wan Kenobi",
		"Yoda",
	}
	dropdown_init(self, "NodeName", ListName, Active)
end
```
Dropdown:

*Returns selected value*
```
dropdown_interact(self, action_id, action, "NodeName",ListName, active(boolean), "TabToNodeName")
```

Combobox:

*Returns selected value*
```
combobox_interact(self, action_id, action, "NodeName",ListName, active(boolean), "TabToNodeName")
```

*Localise standard values*
```
localisationofstrings("Nothing found", "Select")
```
### Text

Textinput:

*Returns text*
```
text_input(self, action_id, action, "NodeName", active(boolean), "TabToNodeName")
```

Textbox:

*Returns text*
```
textbox_input(self, action_id, action, "NodeName", active(boolean), "TabToNodeName")
```
*Clear textbox and input trough script*
```
textbox_clear("box")
```

