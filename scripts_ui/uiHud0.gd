extends Control


func _ready():
	pass # Replace with function body.

func _process(_delta):
	# pull godot node of controlled ship
	
	var z0 = get_node(NodePath("/root/rootNode/entities"))
	var controlledNode = z0.find_child(input0.controlledEntityName)
	
	if controlledNode != null:
		var temperatureStr0: String = str(controlledNode.temperature + -273.0) # convert temperature of frame of vehicle to degree celsius
		var chemicalFuelStr: String = str(controlledNode.fuelMassRemaining)
		var massStr: String = str(controlledNode.calcMass())
		
		var text: String = ""
		if true: # add DEBUG text?
			text += "\npos: <{x},{y},{z}>".format({"x":controlledNode.position.x,"y":controlledNode.position.y,"z":controlledNode.position.z})
		text += "\ntemp: {tempStr}°C\nmass: {massStr}kg\nchemical fuel: {chemicalFuelStr}kg".format({"tempStr":temperatureStr0, "massStr":massStr, "chemicalFuelStr": chemicalFuelStr})
		
		var labelNode = get_node("./VFlowContainer/statusLabelA")
		labelNode.text = text
