extends MeshInstance3D

# warhead = explosives + fuse to trigger the explosive + (optional thruster)
# fuse can be of serveral modes like
# * proximity fuse
# * timed fuse
#
# TODO< add type of explosive such as "chemical" and "emp" and "nuclear" >

# TODO< add directed thrust so we can build missiles >

var velocity : Vector3


@export var yieldInJoules: float

# either "proximity" or "timed"
@export var fuseType: String

# parameterA for the fuse. interpretation of the value depends on the 
@export var fuseParamA: float



# designated target (name of the vehicle)
var designatedTargetName: String




# expired time since deployment
var expiredTime: float



func _ready():
	expiredTime = 0.0
	
	#yieldInJoules = 0.0
	
	fuseType = "timed"
	#fuseParamA = 15.0
	
	velocity = Vector3(0.0,0.0,0.0)


func _process(delta):
	position += (velocity*delta)
	
	expiredTime += delta
	
	if !is_instance_valid(self):
		return # prevent from exploding multiple times
	
	if fuseType == "timed":
		var isExplode = expiredTime >= fuseParamA
		if isExplode:
			print("warhead exploded")
			
			# damage all entities nearby
			var entitiesNode = get_node(NodePath(^"/root/rootNode/entities"))
			
			for iEntry in entitiesNode.get_children():
				if !("fakeRadius" in iEntry):
					continue # it doesn't have the property thus it doesn't have the script
				
				var dist = (position - iEntry.position).length()
				
				print("[d] dist={dist}".format({"dist":dist}))
				
				# * compute absorbed energy
				
				# FIXME< this is not exact as computing the solid angle! >
				var equivalentSphereArea: float = 4.0*PI*dist*dist
				var absorbedSphereArea: float = 4.0*PI*iEntry.fakeRadius*iEntry.fakeRadius
				
				var energyAbsorbtionRatio: float = absorbedSphereArea/equivalentSphereArea
				energyAbsorbtionRatio = min(1.0, energyAbsorbtionRatio)
				
				var absorbedThermalEnergy: float = energyAbsorbtionRatio*yieldInJoules # in joules
				
				print("[d] energyAbsorbtionRatio={z0}".format({"z0":energyAbsorbtionRatio}))
				print("[d] absorbedThermalEnergy={z0}".format({"z0":absorbedThermalEnergy}))
				
				
				# * heat up frame of vehicle
				# TODO
				
			
			# delete this entity
			queue_free()
