# script to prototype and test code

extends Node3D

# convert dict to Vec
# used to load json
static func convDictToVec(dict):
	var x = dict["x"]
	var y = dict["y"]
	var z = dict["z"]
	return Vector3(x,y,z)

var cachedEntityVehicleA = preload("res://entities/entityVehicleA.tscn")

func _ready():
	# TODO< should be user for user created scenarios / safegames >
	var filepath = "res://scenarioA.txt"
	
	
	if not FileAccess.file_exists(filepath):
		return # Error! We don't have a save to load.

	# Load the file line by line and process that dictionary to restore
	# the object it represents.
	var save_game = FileAccess.open(filepath, FileAccess.READ)
	while save_game.get_position() < save_game.get_length():
		var jsonStringA = save_game.get_line()
		
		#var jsonStringA = "{\"p\":{\"x\":5.0, \"y\":0.0, \"z\":0.0},  \"v\":{\"x\":0.01, \"y\":0.02, \"z\":0.03}, \"type\": \"vehicleA\", \"teamName\": \"b\", \"name\":\"vehicle-1\"  }"
		
		var json = JSON.new()
		
		# Check if there is any error while parsing the JSON string, skip in case of failure
		var parse_result = json.parse(jsonStringA)
		if not parse_result == OK:
			#print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
			return
			
		# Get the data from the JSON object
		var nodeDat = json.get_data()
		
		var name: String = nodeDat["name"]
		var p: Vector3 = convDictToVec(nodeDat["p"])
		var v: Vector3 = convDictToVec(nodeDat["v"])
		var teamName: String = nodeDat["teamName"]
		var type: String = nodeDat["type"] # is it a ship or a missile, etc.
		
		# * instantiate
		if type == "vehicleA":
			var createdInstance = cachedEntityVehicleA.instantiate()
			get_node(NodePath(^"/root/rootNode/entities")).add_child(createdInstance)
			createdInstance.name = name
			createdInstance.position = p
			createdInstance.velocity = v
			
		elif type == "missile":
			# TODO TODO TODO
			pass
		elif type == "projectile":
			# TODO TODO TODO
			pass
		else:
			# unrecognized type, just ignore
			pass
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if true:
		var space = get_world_3d().direct_space_state
		#var query = PhysicsRayQueryParameters3D.create(
		#	iProjectile["p2"],
		#	iProjectile["p"])
		var query = PhysicsRayQueryParameters3D.create(
			Vector3(0.02, 0.05, 30.0),
			Vector3(0.07, 0.09, -30.0))
		
		
		#query.collision_mask = 2 # only take armor into account
		var collisionInfo = space.intersect_ray(query)
		if collisionInfo:
			# collisionInfo.collider.name
			pass
			
			#print("HIT!!!")
