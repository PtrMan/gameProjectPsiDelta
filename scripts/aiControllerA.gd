extends Node

@export var controlledShipNodeName: String

func _ready():
	pass

func _process(delta):
	var z0 = get_node(NodePath(^"/root/rootNode/entities"))
	var z1 = z0.find_child(controlledShipNodeName)
	
	if z1 != null: # if controlled vehicle was found
		
		z1.controlAxisA = 0.0
		z1.controlYaw = 0.0
		z1.controlFireweapon = false
		z1.controlFireweaponSecondary = false
		
		z1.controlAxisA = 0.05 # accelerate ship forward in this scenario
