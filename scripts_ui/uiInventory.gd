extends Node2D

# script which is used to manage the inventory and trade of items

# @export var isTransfer: bool = false # is this in transfer mode? if so then items can be transfered between two containers



func _on_button_transfer_button_up():
	print("UI: transfer button was pressed")
	
	# now we transfer the selected item
	
	# * locate the selected stack by iNode.containerItemStackId
	var selectedItemLocation = null
	for iNode in $VBoxContainer/containerA.find_child("grid").get_children():
		if iNode.isSelected:
			print("UI: uiInventory: found selected item in containerA!")
			selectedItemLocation = ["containerA", iNode.containerItemStackId]
	for iNode in $VBoxContainer/containerB.find_child("grid").get_children():
		if iNode.isSelected:
			print("UI: uiInventory: found selected item in containerB!")
			selectedItemLocation = ["containerB", iNode.containerItemStackId]
	
	if selectedItemLocation != null: # was any item selected?
		if selectedItemLocation[0] == "containerA": # transfer from containerA to containerB
			var sourceItemStackUniqueId = selectedItemLocation[1]
			InventoryManager.moveAll(sourceItemStackUniqueId, $VBoxContainer/containerB.containerId)
		else: # transfer from containerB to containerA
			var sourceItemStackUniqueId = selectedItemLocation[1]
			InventoryManager.moveAll(sourceItemStackUniqueId, $VBoxContainer/containerA.containerId)
	
	# * update visualization of content + selection
	$VBoxContainer/containerA.updateContainedItems()
	$VBoxContainer/containerB.updateContainedItems()

