# script to prototype and test code

extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
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
