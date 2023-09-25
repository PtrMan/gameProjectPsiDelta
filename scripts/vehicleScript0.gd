extends Node3D

# name of team on which the crew of the ship is on
# can be "" if unmanned
# used by AI to target enemies etc.
@export var teamName: String # commented because not used


# can this vehicle be a destination for travel by the player?
@export var isTravelableDestination: bool = false



# control for forward and backward, in range of -1.0 to 1.0
var controlAxisA: float = 0.0

# control for yaw, in range of -1.0 to 1.0
var controlYaw: float = 0.0

# control for pitch, in range of -1.0 to 1.0
var controlPitch: float = 0.0

# control for pitch, in range of -1.0 to 1.0
var controlRoll: float = 0.0

var controlFireweapon : bool = false
var remainingFireCooldown : float = 0.0


var controlFireweaponSecondary: bool
var remainingFireCooldownSecondary: float = 0.0

@export var weaponSecondaryBulletVelocity: float = 50.0 # bullet velocity of secondary bullet weapon

@export var weaponVehicleTargetNodeName: String

var velocity: Vector3

# orientation of the rigid body of the vehicle
#var rotation2: Basis = Basis()
var orientation2: Quaternion = Quaternion()

@export var angularVelocity: Vector3 = Vector3(0.0,0.0,0.0)

# mass of the frame of the vehicle
@export var frameMass: float = 4000.0

var temperature: float # in Kelvin

@export var fuelMassRemaining: float = 100.0# in kg


# radius used for various calculations where a sphere is assumed such as
# (in meters)
# * cooling of the frame of the vehicle by radiation
# * heat from radiation of nuclear warhead
# * hit calculation with bullets
@export var fakeRadius: float = 4.0


@export var fakeSpecificHeatCapacity: float = 490.0 # average specific heat capacity of frame, set to heat capacity of steel by default


# commented because not fully integrated
# var reactorPseudoHealth: float = 0.0001 # pseudo heath of the reactor, negative if destroyed physically

@export var thrusterPseudoHealth: float = 0.0001
@export var crewPseudoHealth: float = 0.0001

var cachedEntityWarhead = preload("res://entities/entityWarheadA.tscn")

@export var rotationKind: String = "controlled" # "cinematic" or "controlled"

@export var cinematicRotationAxis: Vector3 = Vector3(0.0, 0.0, 1.0)
@export var cinematicRotationAmount: float = 0.3 # amount of cinematic rotation per second in rads


# container game mechanics (cargo)
var cargoContainerId: int





# docking game mechanics
# array of team-tickers which are allowed to dock
# commented because docking is not implemented!
@export var dockingAllowedTeams: Array[String] = []

# docking game mechanics
# holds the vehicle to which this vehicle is docked to
# is "" when this vehicle is not docked to a vehicle
@export var vehicleTargetDocked: String = ""






# -1 if "orbit animation" is disabled
@export var orbitPiviotId: int = -1 # id of celestial (or later piviotPoint) around which this celestial orbits

@export var orbitPlaneNormal: Vector3
@export var orbitPlaneSideVector: Vector3

@export var orbitRadiusA: float
@export var orbitRadiusB: float

@export var orbitalPeriod: float = 1.0e20 # how long does one orbit around the piviot take, in seconds




func _ready():
	add_to_group("vehicleA")
	
	cargoContainerId = InventoryManager.makeContainer()
	
	temperature = 20.0 # kelvin
	
	
	#var axis = Vector3(0, 1, 0) # Or Vector3.RIGHT
	#var rotationAmount = 0.3
	#rotation2 = rotation2.rotated(axis, rotationAmount)

# commented because not used
func actionDockTo(target) -> bool:
	if vehicleTargetDocked != "": # already docked?
		print("warning: vehicle: actionDockTo() called for already docked vehicle! (ignored)")
		return false
	
	var nodeTarget = get_node(NodePath(^"/root/rootNode/entities")).find_child(target)
	if nodeTarget == null:
		# target node doesn't exist
		return false
	
	# docking must happen in docking range
	var isInDockingRange: bool = (nodeTarget.position - position).length() < 7.5
	if not isInDockingRange:
		return false
	
	# TODO< add the mass to the "massDockedToThis" of the target! >
	
	vehicleTargetDocked = target
	return true

func actionUndock():
	if vehicleTargetDocked == "":
		# control flow here indicates some bug in some logic somewhere...
		
		print("warning: vehicle: actionUndock() called for already undocked vehicle! (ignored)")
		return
	
	# TODO< subtract the mass from the "massDockedToThis" of the target! >
	
	vehicleTargetDocked = "" # undock

func retIsDocked() -> bool:
	return vehicleTargetDocked != ""

# checks if this vehicle is able to dock to any other vehicle, which is in docking range
func checkIsInDockingRangeOfAny() -> bool:
	# TODO< also filter for entities where docking is enabled for the team of this vehicle! >
	
	for iNode in get_node(NodePath(^"/root/rootNode/entities")).get_children():
		if iNode.is_in_group("vehicleA"):
			var dist: float = (position - iNode.position).length()
			if dist < 7.5: # is in docking range?
				return true
	return false

# returns node of vehicle of nearest vehicle to which this vehicle can dock to
# returns null if no dockable vehicle is found in a dockable distance
func retNearestDockableVehicle():
	var nearest = null
	var nearestDist: float = 10e30
	
	for iNode in get_node(NodePath(^"/root/rootNode/entities")).get_children():
		if not iNode.is_in_group("vehicleA"):
			continue
		
		if iNode.name == name:
			continue # vehicle can't dock to itself!
		
		var dist: float = (iNode.position - position).length()
		if dist > 7.5:
			continue
		
		if false: # not(teamName in iNode.dockingAllowedTeams)
			continue
			
		if dist < nearestDist:
			nearestDist = dist
			nearest = iNode
	
	return nearest


func _process(delta):
	
	# orbit animation
	if orbitPiviotId != -1: # if this vehicle orbits around a celestial piviot
		# retrieve position of piviot
		var piviotPosition: Vector3 = celestialManager.retPositionByPiviotId(orbitPiviotId)
		
		var orbitPlaneUpVector: Vector3 = orbitPlaneNormal.cross(orbitPlaneSideVector)
		orbitPlaneUpVector = orbitPlaneUpVector.normalized()
		var orbitPlaneSideVector2: Vector3 = orbitPlaneSideVector.normalized()
		
		# TODO MID< compute this based on the game-time >
		var orbitRadiants: float = 0.0/orbitalPeriod
		var a: Vector3 = orbitPlaneUpVector*cos(orbitRadiants)*orbitRadiusA
		var b: Vector3 = orbitPlaneSideVector2*sin(orbitRadiants)*orbitRadiusB
		
		var positionNew: Vector3 = piviotPosition + a + b
		position = positionNew # actual update of position
		
		return # return because it is animated
	
	
	
	var isCrewHealthy: bool = crewPseudoHealth > 0.0
	if !isCrewHealthy:
		# disable all control input because there is no crew to control it
		controlFireweapon = false
		controlFireweaponSecondary = false
		controlAxisA = 0.0
		controlYaw = 0.0
	
	
	if vehicleTargetDocked != "": # if this vehicle is docked to another vehicle
		# try to find the other vehicle to sync up position etc.
		var z0 = get_node(NodePath(^"/root/rootNode/entities/"))
		var nodeDockedTarget = z0.find_child(vehicleTargetDocked)
		
		if nodeDockedTarget != null: # if controlled vehicle was found
			# sync up the physical stuff of the body to the position of the docked body
			position = nodeDockedTarget.position
			velocity = nodeDockedTarget.velocity
			transform.basis = nodeDockedTarget.transform.basis
			
			# now we skip all the other stuff in the handling, because it is not necessary when the vehicle is docked
			return
	
	
	
	var specificHeatCapacityOfBody = fakeSpecificHeatCapacity*frameMass
	
	######
	# compute radiated energy and thus loss of temperature of body
	
	var r = fakeRadius # radius of sphere of body to compute radiated energy
	
	var surfaceArea: float = 4.0*PI*pow(r,2) # assume sphere

	if not get_tree().paused:
		# energy emitted by sphere
		# https://en.wikipedia.org/wiki/Black-body_radiation
		var stefanBoltzmannConstant = 5.670374419e-8
		var effectiveTemperature = temperature - 0.0
		var totalEmittedPower = 4.0*PI*stefanBoltzmannConstant*pow(r, 2)*pow(effectiveTemperature, 4) # in Watts
		totalEmittedPower *= surfaceArea
		temperature -= ((totalEmittedPower / specificHeatCapacityOfBody)*delta) # cool down body
	
	
	######
	# weapon firing logic: missiles
	if not get_tree().paused:
		remainingFireCooldown += delta
		
		if controlFireweapon and remainingFireCooldown > 0.0:
			remainingFireCooldown = -2.0
			
			# log
			if true: # codeblock
				gameLog("{entityName} fired weapon".format({"entityName":name}))
			
			# spawn warhead
			var warheadInstance = cachedEntityWarhead.instantiate()
			get_node(NodePath(^"/root/rootNode/projectiles")).add_child(warheadInstance)
			warheadInstance.position = position + (-transform.basis.z*1.2) # spawn in front of vehicle
			warheadInstance.velocity = velocity + (-transform.basis.z*20.111)
			
			warheadInstance.yieldInJoules = 5.0e9*1.0
			warheadInstance.fuseType = "timed"
			warheadInstance.fuseParamA = 15.0 # set fuse timer
			
			if true: # codeblock to compute fuse timer based on currently selected enemy
				var predictedDirRes = z0({"projectileVelocity":weaponSecondaryBulletVelocity})
				
				print("debug: HERE6544")
				
				if predictedDirRes != null: # is predicted direction to fire valid?
					
					var bulletManagerNode = get_node(NodePath(^"/root/rootNode/bulletManager"))
					
					
					# set fuse timer
					warheadInstance.fuseParamA = predictedDirRes["t"]
					
					print("debug: fuse timer of bomb was set to timer={fuseTimer}".format({"fuseTimer":warheadInstance.fuseParamA}))
	
	######
	# weapon fire logic: projectile weapon
	if not get_tree().paused:
		remainingFireCooldownSecondary += delta
		if controlFireweaponSecondary and remainingFireCooldownSecondary > 0.0:
			remainingFireCooldownSecondary = -0.8
			
			# PROTOTYPING
			var predictedDirRes = z0({"projectileVelocity":weaponSecondaryBulletVelocity})
			if predictedDirRes != null: # is predicted direction to fire valid?
				
				var bulletManagerNode = get_node(NodePath(^"/root/rootNode/bulletManager"))
				
				
				# compute relative velocity of the bullet to the vehicle
				var bulletRelativeVelocity: Vector3 = predictedDirRes["dir"]
				
				bulletRelativeVelocity = bulletRelativeVelocity*weaponSecondaryBulletVelocity
				
				var bulletSpawnPosition: Vector3 = position + (-transform.basis.z*1.2) # spawn in front of vehicle
				var bulletAbsoluteVelocity: Vector3 = velocity + bulletRelativeVelocity
				var bulletMass: float = 0.1 # in kg
				bulletManagerNode.putBullet(bulletSpawnPosition, bulletAbsoluteVelocity, bulletMass)
	
	######
	# 
	
	if not get_tree().paused:
		# HACKY PHYSICS< we set the angular velocity directly, should be accelerated with a MPC controller owned by vehicle >
		angularVelocity.y = controlYaw*1.3
		angularVelocity.x = controlPitch*1.3
		angularVelocity.z = controlRoll*2.1
		
		#var rotationQuaternion = transform.basis.get_rotation_quaternion()
	
	if not get_tree().paused:
		var maxThrust = 30000.0 # in newtons
		var thrustScale = controlAxisA # in range -1.0 to 1.0
		if fuelMassRemaining <= 0.0:
			thrustScale = 0.0
		
		var isThrusterHealthy: bool = thrusterPseudoHealth > 0.0
		if !isThrusterHealthy:
			thrustScale = 0.0 # disable thrust because the thruster is defective
		
		var acceleration = maxThrust / calcMass() # a=m/f
		
		velocity += (-transform.basis.z*thrustScale*delta*acceleration)
		
		# heat up the body of the vehicle if engine is firing
		var spentEnergy = absf(thrustScale*delta*5000.0)
		temperature += physicsThermodynamics.calcHeatingByEnergy(spentEnergy, fakeSpecificHeatCapacity, frameMass)
		
		
		# consume fuel
		fuelMassRemaining -= abs(thrustScale)*0.01*delta
	
	if not get_tree().paused:
		######
		# gravity from celestials
		
		for iCelestial in celestialManager.celestials:
			var diff: Vector3 = position - iCelestial.position
			var forceMag: float = 6.674e-11*((calcMass()*iCelestial.mass)/diff.length_squared()) # newtons law
			var acceleration2: Vector3 = (forceMag*diff.normalized()) / calcMass()
			velocity += (acceleration2*delta)
		
		######
		# rigid body dynamics
		
		position += (velocity*delta)
		
		var quatX: Quaternion = Quaternion(Vector3(1.0,0.0,0.0), angularVelocity.x*delta)
		var quatY: Quaternion = Quaternion(Vector3(0.0,1.0,0.0), angularVelocity.y*delta)
		var quatZ: Quaternion = Quaternion(Vector3(0.0,0.0,1.0), angularVelocity.z*delta)
		orientation2 = orientation2*((quatX*quatY)*quatZ)
		# set rotation to current orientation
		var quat: Quaternion = orientation2.normalized() # we need to normalize before we convert it to Basis
		transform.basis = Basis(quat)

func calcMass():
	return frameMass + fuelMassRemaining

# helper
# returns normalized vector
func retForwardDirection() -> Vector3:
	return -transform.basis.z

func retUpDirection() -> Vector3:
	return transform.basis.y

### commented because not used
# calculate if power is present
#func isPowered():
#	# return reactorPseudoHealth > 0.0 # can only be powered if the reactor is physically healthy
#	return true

# log entry into game log readable by player
func gameLog(text: String):
	# TODO< store to log in global Godot node >
	
	# we just print the message to the debug console
	print("gameLog: "+text)
	
	pass

# function to compute direction of bullet to fire at a moving target
# it also computes if the firing direction is possible to fire from the weapon slot
func z0(argsDict):
	var targetVehicleNode: Node3D = get_node(NodePath(^"/root/rootNode/entities")).find_child(weaponVehicleTargetNodeName)
	if targetVehicleNode == null:
		return # we don't fire the weapon when the target wasn't found
	
	var p: Vector3 = position
	var v: Vector3 = velocity
	
	var targetP: Vector3 = targetVehicleNode.position
	var targetV: Vector3 = targetVehicleNode.velocity
	var targetR: float = 1.0 # TODO # radius of target
	var projectileVelocity: float = argsDict["projectileVelocity"]
	
	var predictedDirRes = aiUtils.calcIntersectionOfObjectAndBullet(p, v, targetP, targetV, targetR, projectileVelocity)
	if predictedDirRes == null:
		return null
	
	# TODO< compute if the weapon slot can fire in the direction and return null if it is not possible to do so >
	
	return predictedDirRes






