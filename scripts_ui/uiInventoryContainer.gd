extends MarginContainer

# prototype of implementation of basic UI for inventory (where the data is stored in a global datastructure in the background)

var sceneInventoryItemA = preload("res://elementScenes_ui/inventoryItemA.tscn")


@export var containerId: int = -1 # id of the global container from which the items of the visuaualized container are being pulled from

func _ready():
	updateContainedItems()

func _on_gui_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed: # handle press left mouse button
		print("gui input: uiInventory: UI inventory item was clicked")
		
		# reset color of items, because they were not selected
		#for iNode in get_node(NodePath(^"./grid")).get_children():
		#	iNode.get_node(NodePath(^"./MarginContainer/ColorRect")).color = Color(0.0, 0.0, 0.3)
		
		# we now reset selection
		for iNode in get_node(NodePath(^"./grid")).get_children():
			iNode.isSelected = false
		
		# scan for inventory item which was clicked
		for iNode in get_node(NodePath(^"./grid")).get_children():
			if iNode.wasClicked:
				iNode.isSelected = true
				
				iNode.wasClicked = false
				print("...found node which was clicked")
				
				break # optimization
	
	updateVisual()

# helper to update visualization of selected item
func updateVisual():
	for iNode in get_node(NodePath(^"./grid")).get_children():
		iNode.get_node(NodePath(^"./MarginContainer/ColorRect")).color = Color(0.0, 0.0, 0.3) # set background to standard
	
	for iNode in get_node(NodePath(^"./grid")).get_children():
		if iNode.isSelected:
			iNode.get_node(NodePath(^"./MarginContainer/ColorRect")).color = Color(1.0, 0.0, 0.0) # set background to selected

# force update of 
func updateContainedItems():
	utils.clearChildren( get_node(NodePath(^"./grid")) )
	
	var items = InventoryManager.retItemsByContainer(containerId)
	for z in items:
		var itemScene = sceneInventoryItemA.instantiate()
		itemScene.get_node(NodePath(^"./MarginContainer/labelAmount")).text = "{amount}x".format({"amount":z.amount})
		
		# TODO< overhaul to lookup the human readable text by id of the item type >
		itemScene.get_node(NodePath(^"./MarginContainer/labelText")).text = z.itemId 
		
		itemScene.containerItemStackId = z.containerItemStackId # do this to be able to uniquly identify the stack when the stack is selected etc.
		
		get_node(NodePath(^"./grid")).add_child(itemScene)
