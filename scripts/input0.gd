# mediates between player input and controlled vehicle

extends Node

class_name input0

#@export_node_path(Resource) var entriesPath
@export var entriesPath : NodePath

# name of the player controlled vehicle, input is ignored if vehicle wasn't found (because it got removed)
static var controlledEntityName: String = "vehicle0"

func _ready():
	pass

func _process(delta):
	var z0 = get_node(entriesPath)
	var controlledNode = z0.find_child(controlledEntityName)
	
	if controlledNode != null: # if controlled vehicle was found
		
		controlledNode.controlAxisA = 0.0
		controlledNode.controlYaw = 0.0
		controlledNode.controlPitch = 0.0
		controlledNode.controlRoll = 0.0
		controlledNode.controlFireweapon = false
		controlledNode.controlFireweaponSecondary = false
		
		if Input.is_action_pressed("forward"):
			#print("forward") # DBG
			
			controlledNode.controlAxisA = 1.0
		
		if Input.is_action_pressed("backward"):
			#print("backward") # DBG
			
			controlledNode.controlAxisA = -1.0
			
		
		if Input.is_action_pressed("yawPos"):
			controlledNode.controlYaw = 1.0
		
		if Input.is_action_pressed("yawNeg"):
			controlledNode.controlYaw = -1.0
		
		if Input.is_action_pressed("pitchPos"):
			controlledNode.controlPitch = 1.0
		
		if Input.is_action_pressed("pitchNeg"):
			controlledNode.controlPitch = -1.0
		
		if Input.is_action_pressed("rollPos"):
			controlledNode.controlRoll = 1.0
		
		if Input.is_action_pressed("rollNeg"):
			controlledNode.controlRoll = -1.0
		
		
		if Input.is_action_pressed("weaponPrimary"):
			controlledNode.controlFireweapon = true
		
		if Input.is_action_pressed("weaponSecondary"):
			controlledNode.controlFireweaponSecondary = true
		
		if Input.is_action_just_released("dock") and not controlledNode.retIsDocked():
			var nodeNearestDockableTarget = controlledNode.retNearestDockableVehicle()
			if nodeNearestDockableTarget != null: # is there a nearest dockable vehicle?
				# then dock to it!
				controlledNode.actionDockTo(nodeNearestDockableTarget.name)
		
		if Input.is_action_just_pressed("showMap"):
			$"../gui_static/solarMap".show2(not $"../gui_static/solarMap".visible)
		
		if Input.is_action_just_pressed("menuConsole"):
			pass
			# TODO LOW< show/hide dev console >
