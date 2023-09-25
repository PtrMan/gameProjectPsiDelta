extends Node3D

var sceneBulletTraceA = preload("res://assets_3d_scenes/effectBulletTraceA.tscn")

func _process(delta):
	utils.clearChildren($"../effect_bulletTraces")
	
	for iProjectile in $"../bulletManager".bullets:
		var nodeBulletTrace: Node3D = sceneBulletTraceA.instantiate()
		# * orient by direction of bullet
		var bulletDir: Vector3 = iProjectile["v"].normalized() # normalized
		var basis: Basis = Basis()
		basis.y = bulletDir
		basis.x = bulletDir.cross(Vector3(0.9999999,0.000001,0.0)).normalized()
		basis.z = basis.x.cross(basis.y).normalized()
		nodeBulletTrace.transform.basis = basis
		
		# * scale by velocity of bullet and shutter speed of simulated camera
		var velMagnitude: float = iProjectile["v"].length()
		nodeBulletTrace.scale = Vector3(1.0,velMagnitude/60.0,1.0)
		$"../effect_bulletTraces".add_child(nodeBulletTrace)
		

