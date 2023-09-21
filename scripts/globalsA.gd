extends Node

class_name globalsA

var sceneBulletTraceA = preload("res://assets_3d_scenes/effectBulletTraceA.tscn")

func _ready():
	# enable ambient light for PROTOTYPING
	$"/root/rootNode/env".environment.ambient_light_energy = 0.25
	
	
	
	
	# add items to containers
	InventoryManager.put("a0", 2, 1, 1)
	InventoryManager.put("a1", 3, 1, 2)
	InventoryManager.put("a2", 4, 1, 3)
	
	InventoryManager.put("a0", 2, 2, 4)
	InventoryManager.put("a1", 3, 2, 5)
	InventoryManager.put("a2", 4, 2, 6)
	
	
	
	# append celestrial for testing code
	var c0: celestialManager.Celestial = celestialManager.Celestial.new()
	c0.position = Vector3(70000.0, 0.0, -150000.0)
	c0.mass = 0.0
	c0.id = 0
	c0.radiusMax = 20000.0
	c0.isEmissive = true # make it to appear like a glowing star
	celestialManager.celestials.append(c0)
	
	
	# celestial which orbits c0
	var c1: celestialManager.Celestial = celestialManager.Celestial.new()
	c1.position = Vector3(-70000.0, 0.0, -150000.0)
	c1.mass = 0.0
	c1.id = 1
	c1.radiusMax = 20000.0
	c1.piviotId = 0
	c1.orbitPlaneNormal = Vector3(0.0, 1.0, 0.0)
	c1.orbitPlaneSideVector = Vector3(1.0, 0.0, 0.0)
	c1.orbitRadiusA = 34000.0
	c1.orbitRadiusB = 34000.0
	celestialManager.celestials.append(c1)
	
	print("HERE globalsA 85858585885")
	
	
	
	
	# GUI: hide map
	$"/root/rootNode/gui_static/solarMap".visible = false
	
	
	
	
	# PROTOTYPING!!! < bullet trace effect >
	# TODO< do this in bulletTraceEffect script which is attached to node "effect_bulletTraces" >
	
	utils.clearChildren($"../effect_bulletTraces")
	
	var nodeBulletTrace: Node3D = sceneBulletTraceA.instantiate()
	# * orient by direction of bullet
	var bulletDir: Vector3 = Vector3(0.0, 1.0, 0.0) # normalized
	var basis: Basis = Basis()
	basis.y = bulletDir
	basis.x = bulletDir.cross(Vector3(0.9999999,0.000001,0.0)).normalized()
	basis.z = basis.x.cross(basis.y).normalized()
	nodeBulletTrace.transform.basis = basis
	
	# * scale by velocity of bullet and shutter speed of simulated camera
	var velMagnitude: float = 700.0
	nodeBulletTrace.scale = Vector3(1.0,velMagnitude/60.0,1.0)
	$"../effect_bulletTraces".add_child(nodeBulletTrace)

func _process(delta):
	pass


