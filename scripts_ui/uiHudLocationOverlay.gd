# script which draws positions of the bullets, missiles, etc. on the HUD for the player

extends Node2D

func _process(delta):
	queue_redraw() # force redraw


func _draw():
	var bulletManagerNode = get_node(NodePath(^"/root/rootNode/bulletManager"))
	
	var currentCamera = utils.retCamera(self)
	
	
	for iProjectile in bulletManagerNode.bullets:
		var diff: Vector3 = iProjectile["p"]-currentCamera.global_transform.origin
		var cameraDir: Vector3 = -currentCamera.global_transform.basis.z.normalized()
		var diffNormalized: Vector3 = diff.normalized()
		
		if cameraDir.dot(diffNormalized) > 0.0: # must be in fornt of camera to be drawn
			var projPos: Vector2 = currentCamera.unproject_position(iProjectile["p"])
			draw_line(projPos - Vector2(4, 0), projPos + Vector2(4, 0), Color(1.0, 1.0, 1.0))
			draw_line(projPos - Vector2(0, 4), projPos + Vector2(0, 4), Color(1.0, 1.0, 1.0))




