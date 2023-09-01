# mediates between player input and controlled vehicle

extends Node

#@export_node_path(Resource) var entriesPath
@export var entriesPath : NodePath

func _ready():
	pass

func _process(delta):
	#if Input.is_key_pressed(KEY_SHIFT):
	#	print("Ouch...")
	
	var z0 = get_node(entriesPath)
	var z1 = z0.find_child("vehicle0")
	
	if z1 != null: # if controlled vehicle was found
		
		z1.controlAxisA = 0.0
		z1.controlYaw = 0.0
		z1.controlFireweapon = false
		z1.controlFireweaponSecondary = false
		
		if Input.is_action_pressed("forward"):
			#print("forward") # DBG
			
			z1.controlAxisA = 1.0
		
		if Input.is_action_pressed("backward"):
			#print("backward") # DBG
			
			z1.controlAxisA = -1.0
			
		
		if Input.is_action_pressed("yawPos"):
			z1.controlYaw = 1.0
		
		if Input.is_action_pressed("yawNeg"):
			z1.controlYaw = -1.0
		
		
		if Input.is_action_pressed("weaponPrimary"):
			z1.controlFireweapon = true
		
		if Input.is_action_pressed("weaponSecondary"):
			z1.controlFireweaponSecondary = true
