extends Node3D

# name of team on which the crew of the ship is on
# can be "" if unmanned
# used by AI to target enemies etc.
@export var teamName: String # commented because not used

# control for forward and backward, in range of -1.0 to 1.0
var controlAxisA : float

# control for yaw, in range of -1.0 to 1.0
var controlYaw : float


var controlFireweapon : bool
var remainingFireCooldown : float


var controlFireweaponSecondary: bool
var remainingFireCooldownSecondary: float

@export var weaponSecondaryBulletVelocity: float = 50.0 # bullet velocity of secondary bullet weapon

@export var weaponVehicleTargetNodeName: String

var velocity : Vector3

# accumulated orientation
var rotation2 : Basis

# mass of the frame of the vehicle
var frameMass : float

var temperature: float # in Kelvin

var fuelMassRemaining: float # in kg


# radius used for various calculations where a sphere is assumed such as
# (in meters)
# * cooling of the frame of the vehicle by radiation
# * heat from radiation of nuclear warhead
# * hit calculation with bullets
var fakeRadius: float


@export var fakeSpecificHeatCapacity: float = 490.0 # average specific heat capacity of frame, set to heat capacity of steel by default


# commented because not fully integrated
# var reactorPseudoHealth: float = 0.0001 # pseudo heath of the reactor, negative if destroyed physically

var thrusterPseudoHealth: float = 0.0001

var cachedEntityWarhead = preload("res://entities/entityWarheadA.tscn")


func _ready():
	remainingFireCooldown = 0.0
	
	temperature = 20.0 # kelvin
	
	fakeRadius = 4.0 # in meters
	
	frameMass = 4000.0
	fuelMassRemaining = 100.0
	
	controlYaw = 0.0
	
	controlAxisA = 0.0
	
	rotation2 = Basis()
	#var axis = Vector3(0, 1, 0) # Or Vector3.RIGHT
	#var rotationAmount = 0.3
	#rotation2 = rotation2.rotated(axis, rotationAmount)


func _process(delta):
	
	var specificHeatCapacityOfBody = fakeSpecificHeatCapacity*frameMass
	
	######
	# compute radiated energy and thus loss of temperature of body
	
	var r = fakeRadius # radius of sphere of body to compute radiated energy
	
	var surfaceArea: float = 4.0*PI*pow(r,2) # assume sphere


	# energy emitted by sphere
	# https://en.wikipedia.org/wiki/Black-body_radiation
	var stefanBoltzmannConstant = 5.670374419e-8
	var effectiveTemperature = temperature - 0.0
	var totalEmittedPower = 4.0*PI*stefanBoltzmannConstant*pow(r, 2)*pow(effectiveTemperature, 4) # in Watts
	totalEmittedPower *= surfaceArea
	temperature -= ((totalEmittedPower / specificHeatCapacityOfBody)*delta) # cool down body
	
	
	######
	# weapon firing logic: missiles
	
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
	
	######
	# weapon fire logic: projectile weapon
	
	remainingFireCooldownSecondary += delta
	if controlFireweaponSecondary and remainingFireCooldownSecondary > 0.0:
		remainingFireCooldownSecondary = -0.8
		
		# PROTOTYPING
		var predictedDirRes = z0({"projectileVelocity":weaponSecondaryBulletVelocity})
		if predictedDirRes != null: # is predicted direction to fire valid?
			
			var bulletManagerNode = get_node(NodePath(^"/root/rootNode/bulletManager"))
			
			
			# compute relative velocity of the bullet to the vehicle
			var bulletRelativeVelocity: Vector3 = predictedDirRes
			
			bulletRelativeVelocity = bulletRelativeVelocity*weaponSecondaryBulletVelocity
			
			var bulletSpawnPosition: Vector3 = position + (-transform.basis.z*1.2) # spawn in front of vehicle
			var bulletAbsoluteVelocity: Vector3 = velocity + bulletRelativeVelocity
			var bulletMass: float = 0.1 # in kg
			bulletManagerNode.putBullet(bulletSpawnPosition, bulletAbsoluteVelocity, bulletMass)
	
	######
	# 
	
	
	var axis = Vector3(0, 1, 0)
	var rotationAmount = controlYaw*delta*1.8
	rotation2 = rotation2.rotated(axis, rotationAmount)
	
	
	# set rotation to current orientation
	transform.basis = rotation2
	
	#var rotationQuaternion = transform.basis.get_rotation_quaternion()
	
	
	var maxThrust = 10000.0 # in newtons
	var thrustScale = controlAxisA # in range -1.0 to 1.0
	if fuelMassRemaining <= 0.0:
		thrustScale = 0.0
	
	var isThrusterHealthy: bool = thrusterPseudoHealth > 0.0
	if !isThrusterHealthy:
		thrustScale = 0.0 # disable thrust because the thruster is defective
	
	var acceleration = maxThrust / calcMass() # a=m/f
	
	velocity += (-transform.basis.z*thrustScale*delta*acceleration)
	
	temperature += absf(thrustScale*delta*5000.0 / specificHeatCapacityOfBody) # heat up the body of the vehicle if engine is firing
	
	# consume fuel
	fuelMassRemaining -= abs(thrustScale)*0.01*delta
	
	
	######
	# rigid body dynamics
	
	position += (velocity*delta)

func calcMass():
	return frameMass + fuelMassRemaining

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
	
	var aiUtilsNode = get_node(NodePath(^"/root/rootNode/aiUtils"))
	var predictedDirRes = aiUtilsNode.calcIntersectionOfObjectAndBullet(p, v, targetP, targetV, targetR, projectileVelocity)
	if predictedDirRes == null:
		return null
	
	# TODO< compute if the weapon slot can fire in the direction and return null if it is not possible to do so >
	
	return predictedDirRes
