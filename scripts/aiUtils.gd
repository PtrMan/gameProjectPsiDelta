# generic AI utilities

extends Node3D

class_name aiUtils

#func _ready():
#	pass
#func _process(delta):
#	pass

# compute projected position
# will return null if it cant be found
static func calcIntersectionOfObjectAndBullet(p: Vector3, v: Vector3, targetP: Vector3, targetV: Vector3, targetR: float, projectileVelocity: float):
	# see https://math.stackexchange.com/questions/1603637/where-to-shoot-to-hit-a-moving-target-in-3d-space
	# see https://stackoverflow.com/questions/17204513/how-to-find-the-interception-coordinates-of-a-moving-target-in-3d-space?noredirect=1&lq=1
	
	
	# but we solve it here with explicit sphere tracing
	
	var relP: Vector3 = targetP-p
	var relV: Vector3 = targetV-v
	
	var d: float = 0.0
	var t: float = 0.0 # time it took to hit
	
	var itCnt: int = 0
	
	var isHit: bool = false
	
	while itCnt < 60*70:
		itCnt+=1
		
		var dt = 1.0/60.0
		
		d += (projectileVelocity*dt)
		relP += (relV*dt)
		t += dt
		
		var dist: float = relP.length()
		
		isHit = dist<d
		if isHit:
			break
	
	if isHit:
		# compute the normalized target vector to shoot at!
		return {"dir":relP.normalized(), "t":t}
	else:
		return null
