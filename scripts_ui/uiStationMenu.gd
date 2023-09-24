extends Control

# UI script for menu when docked to a station



func _ready():
	pass

func _on_undock_button_button_up():
	print("GUI: stationMenu: undock button was pressed!")
	
	# implementation of triggering of actual undocking
	var z0 = get_node(NodePath(^"/root/rootNode/entities/"))
	var nodeControlledVehicle = z0.find_child(input0.controlledEntityName)
	if nodeControlledVehicle != null: # does vehicle exist?
		nodeControlledVehicle.actionUndock()

func _process(deltaT):
	# * switch visibility of this GUI based on if the controlled vehicle is docked
	var visibleNew: bool = false
	
	var z0 = get_node(NodePath(^"/root/rootNode/entities/"))
	var nodeControlledVehicle = z0.find_child(input0.controlledEntityName)
	if nodeControlledVehicle != null: # does vehicle exist?
		var isDocked: bool = nodeControlledVehicle.retIsDocked()
		visibleNew = isDocked # this GUI is visible if the controlled ship is docked
	
	if visibleNew != visible:
		visible = visibleNew
