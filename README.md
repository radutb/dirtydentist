# DirtyDentist-GUI (DD-GUI)
A basic GUI library for Defold developed for a educational software. It covers the essentials including; comboboxes, auto-suggestbox, simple buttons, checkboxes, radio buttons, text fields and text boxes. Notably, the text components allow for mid-string editing and navigation using arrow keys.

Since rebuild in 0.3.0 functions and implementations have changed but old codebase is included for compability. 

[HTML5 Example](https://skogsheden.se/dirtydentist)

![Screenshot](/screenshot.png)

## Implementation

Use included prefabs and name after hearts content. Implement in GUI script under function on_input(self, action_id, action) as described below if not else specified. 

### Buttons
**Simple button:**

*Function returns true or false*
```
button(self, action_id, action, node, enabled, accent, text)
```
*Turn button on and of not trough input method*
```
toggleActive(self, node, enabled)
```
**Toggle button:**
*Toggle button - turns on and off*
```
togglebutton(self, action_id, action, node, enabled, text)
```

**Checkbox:**

*Function returns true or false*
```
checkbox(self, action_id, action, node, enabled, standard_value, text)
```
*Clear checkboxs trough script*
```
clearCheckbox (self, node)
```
*Select all/three state checkbox*
```
checkboxSelectall(self, action_id, action, node, othernodes, enabled, standard_value, text)
```
**Radiobutton:**

*Function which button that is selected*
```
radiobutton(self, action_id, action, node, enabled, group)
```

### Slider
*Function returns value between min and max*

```
slider(self, action_id, action, node, enabled, showpopup, min, max)
```
*Reset values*

```
resetSlider(self, node)
```

### Combobox

**Simple dropdown:**

*Returns selected value*
```
dropdown_interact(self, action_id, action, "NodeName",ListName, active(boolean), "TabToNodeName")
```

**Combobox:**

*Returns selected value*
```
combobox(self, action_id, action, node, list, enabled, up, use_mag, standardValue)
```
*Set values trough script*
```
setValueCombobox(self, node, value)
```
**Auto suggestbox:**

*Returns selected value and takes text input for search*
```
auto_suggestbox(self, action_id, action, node, list, enabled, up, use_mag, id, tab_to)
```
*Set values trough script*
```
setValueAutobox(self, node, value, active)
```
*Localise standard values*
```
localisation_of_strings("Nothing found", "Select")
```

### Text

**Textbox:**

*Returns text*
```
textbox(self, action_id, action, node, enabled, tab_to)
```

*Clear textbox*
```
clearTextbox(self, node)
```
*Set textbox*
```
setTextbox(self, node, text)
```

**Multi-line textbox:**

*Returns text*
```
textboxMultiline(self, action_id, action, node, enabled, tab_to)
```
*Clear textbox and input trough script*
```
clearTextbox(self, node)
```

