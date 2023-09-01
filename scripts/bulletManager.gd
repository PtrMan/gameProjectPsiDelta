# script for the management of flying bullets

extends Node3D

# list of bullets
# every bullet is represented as a dict of "p", "p2" for the position in the last frame, and "v" and "mass", "age"
var bullets = []

func _ready():
	# hack for testing collision
	#putBullet(Vector3(0.0, 0.0, 5.0), Vector3(0.0, 0.0, -1.0), 0.1)
	
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var space = get_world_3d().direct_space_state
	#var query = PhysicsRayQueryParameters3D.create(
	#	iProjectile["p2"],
	#	iProjectile["p"])
	var query = PhysicsRayQueryParameters3D.create(
		Vector3(0.0, 0.0, 30.0),
		Vector3(0.0, 0.0, -30.0))
	
	
	#query.collision_mask = 2 # only take armor into account
	var collisionInfo = space.intersect_ray(query)
	if collisionInfo:
		# collisionInfo.collider.name
		pass
	
	#collisionInfo = space.intersect_ray(query)
	#if collisionInfo:
	#	# collisionInfo.collider.name
	#	pass
	
	for idx in range(len(bullets)):
		bullets[idx]["age"] += delta

	# move bullets
	for idx in range(len(bullets)):
		bullets[idx]["p2"] = bullets[idx]["p"]
		bullets[idx]["p"] = bullets[idx]["p"] + (bullets[idx]["v"]*delta)
	
	# check collision of bullets with vehicles
	#var bullets2
	#bullets2 = []
	#for iBullet in bullets:
	#	if iBullet["age"] < 0.0:
	#		continue # give the bullet time to leave the bounding sphere of the ship which fired the bullet
	#	
	#	var isBulletAnyHit: bool = false
	#	
	#	var entitiesNode = get_node(NodePath(^"/root/rootNode/entities"))
	#	var vehiclesNodes = entitiesNode.get_children()
	#	for iVehicle in vehiclesNodes:
	#		
	#		if !("fakeRadius" in iVehicle):
	#			continue # it doesn't have the property thus it doesn't have the script
	#		
	#		
	#		var isHit: bool = false
	#		
	#		var diff: Vector3 = iBullet["p"] - iBullet["p2"] 
	#		var rayOrgin: Vector3 = iBullet["p2"]
	#		var rayDir: Vector3 = diff.normalized()
	#		var raySphereIntersectionResult = _calcRaySphereIntersection(rayOrgin, rayDir, iVehicle.position, iVehicle.fakeRadius)
	#		if raySphereIntersectionResult != null:
	#			var tHit: float = raySphereIntersectionResult[0]
	#			if tHit < 0.0:
	#				pass
	#			elif tHit > diff.length():
	#				pass
	#			else:
	#				isHit = true
	#		
	#		isBulletAnyHit = isBulletAnyHit or isHit
	#		
	#		if isHit:
	#			print("[d] bullet: did hit vehicle".format({}))
	#			
	#			# damage vehicle
	#			# TODO
	#			
	#			pass
	#		
	#	if !isBulletAnyHit:
	#		bullets2.append(iBullet)
	#
	#bullets=bullets2
	
	# * check collision of projectile with armor plates
	var bullets2
	bullets2 = []
	for iProjectile in bullets:
		var isBulletAnyHit: bool = false
		

		if iProjectile["age"] > 10.0: # give the bullet time to leave the bounding sphere of the ship which fired the bullet
			
			
			
			var entitiesNode = get_node(NodePath(^"/root/rootNode/entities"))
			var vehiclesNodes = entitiesNode.get_children()
			for iVehicle in vehiclesNodes:
				
				if !("fakeRadius" in iVehicle):
					continue # it doesn't have the property thus it doesn't have the script
				
				
				var diff: Vector3 = iProjectile["p"]-iProjectile["p2"]
				
				var planeCenter: Vector3 = iVehicle.position + (-iVehicle.transform.basis.z*-2.0)
				var planeNormal: Vector3 = (-iVehicle.transform.basis.z*-1.0).normalized()
				var intersectionRes = _calcRayPlaneIntersection(iProjectile["p2"], diff.normalized(), planeCenter, planeNormal)
				
				var armorCircleRadius: float = 5.0
				
				if intersectionRes != null and intersectionRes > 0.0:
					if diff.length() < intersectionRes: # is the intersection in the interval between "p" and "p2" ?
						
						var intersectionAbsoluteP: Vector3 = iProjectile["p2"] + diff.normalized()*intersectionRes
						
						var relPosition: Vector3 = planeCenter - intersectionAbsoluteP
						if relPosition.length() < armorCircleRadius:
							
							print("[d] projectile did hit armor plate")
							
							# TODO LOW< implement code to compute richotete here!!! >
							
							isBulletAnyHit = true # stop bullet
			
			
			### DOESNT WORK BEGIN
			
			#var space = get_world_3d().direct_space_state
			#var query = PhysicsRayQueryParameters3D.create(
			#	iProjectile["p2"],
			#	iProjectile["p"]+Vector3(0.00001, 0.00001, 0.000001))
			#var query = PhysicsRayQueryParameters3D.create(
			#	Vector3(0.02, 0.05, 10.0),
			#	Vector3(0.07, 0.09, -10.0))
			#query.from = iProjectile["p2"]
			#query.to = iProjectile["p"]
			
			#query = PhysicsRayQueryParameters3D.create(
			#Vector3(0.0, 0.0, 30.0),
			#Vector3(0.0, 0.0, -30.0))
			
			#query.from = Vector3(0.0, 0.0, 30.0)
			#query.to = Vector3(0.0, 0.0, -30.0)
			
			#query.collision_mask = 2 # only take armor into account
			#collisionInfo = space.intersect_ray(query)
			#if collisionInfo:
			#	# collisionInfo.collider.name
			#	pass
			#	
			#	isBulletAnyHit = true
			
			### DOESNT WORK END
		
		if !isBulletAnyHit:
			bullets2.append(iProjectile)
	bullets=bullets2
	
	# remove bullets which have a lifetime which is to high
	bullets2 = []
	for iBullet in bullets:
		if iBullet["age"] > 60.0:
			continue
		bullets2.append(iBullet)
	bullets=bullets2

func putBullet(p: Vector3, v: Vector3, mass: float):
	var created = {"p":p,"p2":p,"v":v,"mass":mass,"age":0.0}
	bullets.append(created)




static func _solveQuadratic(a: float, b: float, c: float):
	# see https://www.scratchapixel.com/lessons/3d-basic-rendering/minimal-ray-tracer-rendering-simple-shapes/ray-sphere-intersection.html
	# (code there is buggy)
	
	var discr = b*b - 4.0*a*c
	if discr < 0.0:
		return null
	elif discr >= 0.0:
		var x0 = (-b + sqrt(discr)) / (2.0*a)
		var x1 = (-b - sqrt(discr)) / (2.0*a)
		return [x0, x1]

static func _calcRaySphereIntersection(rayOrigin: Vector3, rayDir: Vector3, center: Vector3, r: float):
	# see https://www.scratchapixel.com/lessons/3d-basic-rendering/minimal-ray-tracer-rendering-simple-shapes/ray-sphere-intersection.html
	
	var diff = rayOrigin - center
	var a: float = rayDir.dot(rayDir)
	var b: float = 2.0 * rayDir.dot(diff)
	var c: float = diff.dot(diff) - r*r
	return _solveQuadratic(a, b, c)



static func _calcRayPlaneIntersection(rayOrigin: Vector3, rayDirection: Vector3, planeCenter: Vector3, planeNormal: Vector3):
	# code from https://stackoverflow.com/questions/23975555/how-to-do-ray-plane-intersection
	
	var denom: float = planeNormal.dot(rayDirection)
	if (abs(denom) > 0.0001):
		var t: float = (planeCenter - rayOrigin).dot(planeNormal) / denom
		return t
	
	return null

