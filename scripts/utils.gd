extends Node

# generic utilities

class_name utils

static func clearChildren(node):
	# code is from https://www.reddit.com/r/godot/comments/9qmjfj/remove_all_children/
	for z in node.get_children():
		node.remove_child(z)
		z.queue_free()


# TODO< move to utilsGame >
static func retVehicles(z) -> Array[Node3D]:
	var res: Array[Node3D] = []
	for iNode in z.get_node(NodePath(^"/root/rootNode/entities")).get_children():
		if not iNode.is_in_group("vehicleA"):
			continue
		res.append(iNode)
	return res

# TODO< move to utilsGame >
static func retCamera(z):
	var z0 = z.get_node(NodePath(^"/root/rootNode/entities"))
	var z1 = z0.find_child(input0.controlledEntityName)
	var currentCamera = z1.find_child("Camera3D")
	return currentCamera

