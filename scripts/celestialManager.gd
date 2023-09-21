extends Node

class_name celestialManager

class Celestial:
	var isEmissive: bool = false
	
	var position: Vector3
	var mass: float
	
	var radiusMax: float # maximal radius of this celestial - is the maximal distance from the center of the celestial body to the outer endge of the celestial body
	
	var id: int # unique id
	
	var piviotId: int = -1 # id of celestial (or later piviotPoint) around which this celestial orbits
	
	var orbitPlaneNormal: Vector3
	var orbitPlaneSideVector: Vector3
	
	var orbitRadiusA: float
	var orbitRadiusB: float
	
	var orbitalPeriod: float = 1.0e20 # how long does one orbit around the piviot take, in seconds


# list of all celestials
static var celestials: Array[Celestial] = []

static var frameCnt: int = 0


static var cachedCelestialA = preload("res://entities_celestials/celestialA.tscn")
static var cachedCelestialEmissiveA = preload("res://entities_celestials/celestialEmissiveA.tscn")

func _ready():
	pass

func _process(delta):
	frameCnt+=1
	
	# TODO LOW< do this calculation every 0.5 seconds or so >
	if (frameCnt % 20) != 0:
		return
	
	updateCelestials()

func updateCelestials():
	# assumption: order of update of celestials is based on index of celestial in the array of celestials!
	
	for idx in range(celestials.size()):
		var i: Celestial = celestials[idx]
		
		if i.piviotId != -1: # if this celestial orbits around another
			# retrieve position of piviot
			var piviotPosition = retPositionByPiviotId(i.piviotId)
			
			var orbitPlaneUpVector: Vector3 = i.orbitPlaneNormal.cross(i.orbitPlaneSideVector)
			orbitPlaneUpVector = orbitPlaneUpVector.normalized()
			var orbitPlaneSideVector: Vector3 = i.orbitPlaneSideVector.normalized()
			
			# TODO MID< compute this based on the game-time >
			var orbitRadiants: float = 0.0/i.orbitalPeriod
			var a: Vector3 = orbitPlaneUpVector*cos(orbitRadiants)*i.orbitRadiusA
			var b: Vector3 = orbitPlaneSideVector*sin(orbitRadiants)*i.orbitRadiusB
			
			celestials[idx].position = piviotPosition + a + b # actual update of position
	
	var currentCamera = utils.retCamera(self)
	var cameraPosition = currentCamera.global_transform.origin

	
	# update nodes in scene
	var nodeFakebackdropCelestials = get_node(NodePath(^"/root/rootNode/fakeBackdrop_celestials"))
	utils.clearChildren(nodeFakebackdropCelestials)
	for iCelestial in celestials:
		
		
		var maxCelestialProjectedDist: float = 4000.0 # maximal distance of a celestial from the camera in worldspace
		
		var diff: Vector3 = iCelestial.position-cameraPosition
		var distToCelestial: float = diff.length()
		
		# compute the scaling of the size of the celestial
		var sizeScale: float = maxCelestialProjectedDist/distToCelestial
		
		var projectedSize: float = iCelestial.radiusMax*sizeScale
		
		# compute relative position from camera
		var relPosition: Vector3 = diff.normalized()*maxCelestialProjectedDist
		
		var projectedWorldPosition: Vector3 = cameraPosition + relPosition
		
		
		# spawn node
		var nodeCelestial
		if iCelestial.isEmissive:
			nodeCelestial = cachedCelestialEmissiveA.instantiate()
		else:
			nodeCelestial = cachedCelestialA.instantiate()
		
		nodeCelestial.scale = Vector3(1.0,1.0,1.0)*projectedSize
		nodeCelestial.position = projectedWorldPosition
		get_node(NodePath(^"/root/rootNode/fakeBackdrop_celestials")).add_child(nodeCelestial)
		

		
		
		# OLD CODE
		#var positionScaleFactor: float = 0.01 # HACK around camera far plane
		#
		## spawn node
		#var nodeCelestial
		#if iCelestial.isEmissive:
		#	nodeCelestial = cachedCelestialEmissiveA.instantiate()
		#	
		#	# TODO LOW< add radius to celestials and use the radius here for scaling >
		#	# HACK
		#	nodeCelestial.scale = Vector3(1.0,1.0,1.0)*700.0
		#else:
		#	nodeCelestial = cachedCelestialA.instantiate()
		#get_node(NodePath(^"/root/rootNode/projectiles")).add_child(nodeCelestial)
		#
		#
		## TODO LOW< take absolute world position of camera into account by subtracting
		#nodeCelestial.position = positionScaleFactor * (iCelestial.position)


static func retPositionByPiviotId(piviotId):
	for i in celestials:
		if i.id == piviotId:
			return i.position
	
	return null

static func tryLookupCelestialById(celestialId):
	for i in celestials:
		if i.id == celestialId:
			return i
	return null
