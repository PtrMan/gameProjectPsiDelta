extends Node

# low level control of vehicle
#
# purpose:
# only implements low level basic movement instructions, but NOT complex movement behaviours or high level behaviours!

@export var controlledShipNodeName: String

# base instruction
# "nop" : doing nothing
# "forward" : accelerate forward - mainly used for PROTOTYPING
# "orient" : orient in direction "orientTargetDir"
# "matchVelocityForward" : match the velocity to the same velocity of a target vehicle   (TODO TOIMPLEMENT)
@export var selBaseInstr: String = "forward"

# target direction for "orient" instruction
# should be normalized
@export var orientTargetDir: Vector3 = Vector3(1.0, 0.00001, 1.0)

func _ready():
	pass

func _process(delta):
	var z0 = get_node(NodePath(^"/root/rootNode/entities"))
	var nodeControlled: Node3D = z0.find_child(controlledShipNodeName)
	
	if nodeControlled == null:
		return # we have no vehicle to control if it wasn't found
	
	nodeControlled.controlAxisA = 0.0
	nodeControlled.controlYaw = 0.0
	nodeControlled.controlFireweapon = false
	nodeControlled.controlFireweaponSecondary = false
	
	if selBaseInstr == "nop":
		pass
	elif selBaseInstr == "forward": 
		nodeControlled.controlAxisA = 0.05 # accelerate ship forward in this scenario
	elif selBaseInstr == "orient":
		var orientTargetDirNormalized: Vector3 = orientTargetDir.normalized()
		
		var planeForward: Vector3 = nodeControlled.retForwardDirection()
		var planeNormal: Vector3 = nodeControlled.retUpDirection()
		var planeTangent: Vector3 = planeForward.cross(planeNormal)
		
		
		var yawRes: float = orientTargetDirNormalized.dot(planeTangent)
		var pitchRes: float = orientTargetDirNormalized.dot(planeNormal)
		
		
		#print("yaw:{yaw} pitch:{pitch}".format({"yaw":yawRes,"pitch":pitchRes})) # DBG
		
		# * compute control
		
		# TODO< this is very basic code here, should get enhanced in the future to support a angle where no control corrections are sent to the controlled vehicle >
		nodeControlled.controlYaw = clampf(yawRes*1e10, -1.0, 1.0)
		# nodeControlled.controlPitch = clampf(pitchRes*1e10, -1.0, 1.0)
		
	elif selBaseInstr == "matchVelocityForward":
		# this assumes that the vehicle is already sort of aligned in formward direction to the target
		# we do NOT change the attitude here!
		
		# TODO LOW< implement me! >
		pass
		
		
