# script for node which shows map of solar system

extends Control

var sceneButton = preload("res://elementScenes_ui/buttonA.tscn")

# id of the selected destination to travel to
var selectedDestinationId = null

func show2(visible2):
	selectedDestinationId = null
	
	
	var nodeDestinations = $destinationButtons/VBoxContainer
	
	if visible2 == true:
		# scan scene for vehicles to which the user can travel to and instatiate buttons for these destinations!
		
		var nodeEntities = get_node(NodePath(^"/root/rootNode/entities"))
		
		for iEntity in nodeEntities.get_children():
			if not iEntity.is_in_group("vehicleA"):
				continue
			
			# filter for travelable vehicles
			if not iEntity.isTravelableDestination:
				continue
			
			var nodeButton = sceneButton.instantiate()
			var nodeButton2 = nodeButton.find_child("Button")
			nodeButton2.text = iEntity.name # TODO LOW< lookup localized name >
			nodeButton2.connect("button_up", _on_buttonUp_destination.bind(["vehicle", iEntity.name]))
			nodeDestinations.add_child(nodeButton)
		
		
	
	visible = visible2

func _on_button_travel_to_button_up():
	# FIXME LOW< user triggered travel to destination,
	#            so we teleport the player controlled ship to a position  >
	
	if selectedDestinationId == null:
		# no destination was selected by user - ignore
		return
	
	var teleportTargetPosition = null # Vector3
	
	if selectedDestinationId[0] == "celestial":
		var selCelestialId: int = selectedDestinationId[1]
		
		var celestial = celestialManager.tryLookupCelestialById(selCelestialId)
		if celestial == null:
			return # no celestial with the id was found, give up
		
		teleportTargetPosition = celestial.position + Vector3(0.0,0.0,1.0)*celestial.radiusMax
		
	elif selectedDestinationId[0] == "vehicle":
		var selVehicleId = selectedDestinationId[1]
		
		# scan for it
		for iNode in get_node(NodePath(^"/root/rootNode/entities")).get_children():
			if not iNode.is_in_group("vehicleA"):
				continue
			
			if iNode.name == selVehicleId:
				# we found the destination vehicle
				teleportTargetPosition = iNode.position + Vector3(0.0,0.0,1.0)*70.0
				
				break # optimization
	
	
	if teleportTargetPosition != null:
		# teleport player controlled vehicle to that position
		for iNode in get_node(NodePath(^"/root/rootNode/entities")).get_children():
			if not iNode.is_in_group("vehicleA"):
				continue
			
			if iNode.name == input0.controlledEntityName:
				iNode.position = teleportTargetPosition
				
				break # optimization

# called when a destination button was pressed
func _on_buttonUp_destination(arg0):
	selectedDestinationId = arg0

