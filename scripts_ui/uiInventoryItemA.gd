extends PanelContainer

var wasClicked: bool = false
var isSelected: bool = false # is the item currently selected?

var containerItemStackId: int = -1 # unique id to be able to refer to the exact stack inside the container

func _on_gui_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed: # handle press left mouse button
		print("gui input: uiInventoryItem: UI inventory item was clicked")
		
		# set variable that this item was clicked! so this information can be retrieved by the parent UI
		wasClicked = true
