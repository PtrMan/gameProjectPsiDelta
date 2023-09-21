extends Node

# global ledger for content of a container
#
# in game: we can use a container for the inventory of the content of the ship cargo
# in game: we can use a container for the fuel tank of a ship

class_name InventoryManager

class InventoryItem:
	var insideContainerId: int # id of the container in which it exists
	var itemId: String # id of the item, for example "Fe" for iron, "missileA" for a missile, etc.
	var amount: float
	var containerItemStackId: int # unique id of the stack

static var globalInventory: Array[InventoryItem] = []

static var globalStackIdCounter: int = 1

static var globalContainerIdCounter: int = 1

static func makeContainer() -> int:
	var res: int = globalContainerIdCounter
	globalContainerIdCounter+=1
	return res

static func retItemsByContainer(containerId) -> Array[InventoryItem]:
	var res: Array[InventoryItem] = []
	for z in globalInventory:
		if z.insideContainerId == containerId:
			res.append(z)
	return res

static func put(itemId, amount, containerId, containerItemStackId):
	if amount < 0.0: # not allowed to remove stuff with this function!!
		return
	
	# TODO< scan for existing itemId in ContainerId with same containerItemStackId and add it >
	
	
	var z = InventoryItem.new()
	z.itemId = itemId
	z.amount = amount
	z.insideContainerId = containerId
	z.containerItemStackId = containerItemStackId
	
	globalInventory.append(z)

# remove all items from the container so it is basically empty
static func clearContainer(containerId):
	var z: Array[InventoryItem] = []
	for i in globalInventory:
		if i.insideContainerId != containerId:
			z.append(i)
	globalInventory = z
	
	gc()

static func checkExistsContainer(containerId) -> bool:
	for i in globalInventory:
		if i.insideContainerId == containerId:
			return true
	
	return false


static func moveAll(sourceStackId, destinationContainerId):
	for i in globalInventory:
		if i.containerItemStackId == sourceStackId:
			return move(sourceStackId, i.amount, destinationContainerId)
	return false

# moves a amount of content from one container to another
# NOT: # assumption: destinationContainerId exists
static func move(sourceStackId, amount, destinationContainerId):
	if amount < 0.0:
		return false # moving from the destination to the source is not valid!
	
	# commented because we don't really make the assumption
	#if not checkExistsContainer(destinationContainerId):
	#	return false # can't move into a non existing container!
	
	for i in globalInventory:
		if i.containerItemStackId == sourceStackId:
			# check if the source has enough amount to be moved
			if i.amount < amount - 1e-7:
				return false # we can't move more than what exists
			
			debugAllItems() # DBG
			
			# * make sure that the itemId exists in container destinationContainerId
			ensureItemIdExistsInContainer(i.itemId, destinationContainerId)
			
			_delta(i.itemId, -amount, i.insideContainerId)
			_delta(i.itemId, amount, destinationContainerId)
			
			debugAllItems() # DBG
			
			# * remove emptied containers
			gc()
			
			debugAllItems() # DBG
			
			return true
			
	return false # failed to move items

# make sure that the itemId exists in container destinationContainerId
# * create the combination with a new stack id if it doesn't exist
static func ensureItemIdExistsInContainer(itemId, insideContainerId):
	for i in globalInventory:
		if i.itemId == itemId and i.insideContainerId == insideContainerId:
			return # it exists so we just return
	
	# we are here if the combination doesn't exist, so we create it with a unique stackId
	var stackId: int = globalStackIdCounter
	globalStackIdCounter+=1
	
	var z: InventoryItem = InventoryItem.new()
	z.insideContainerId = insideContainerId
	z.itemId = itemId
	z.amount = 0.0
	z.containerItemStackId = stackId
	globalInventory.append(z)



static func gc():
	var z: Array[InventoryItem] = []
	for i in globalInventory:
		if i.amount > 1e-7:
			z.append(i)
	globalInventory = z

static func debugAllItems():
	print("---")
	for i in globalInventory:
		print("{containerId} {itemId} {amount} {stackId}".format({"containerId":i.insideContainerId,"itemId":i.itemId,"amount":i.amount,"stackId":i.containerItemStackId}))


# helper to remove a amount or to increment amount
# assumption: the itemId and containerId exist
# assumption: the total amount after the operation is not negative
static func _delta(itemId, amount, containerId):
	for idx in range(globalInventory.size()):
		var i: InventoryItem = globalInventory[idx]
		if i.itemId == itemId and i.insideContainerId == containerId:
			globalInventory[idx].amount += amount
			
			if globalInventory[idx].amount < 0.0:
				print("inventoryLedge: assumption violated: positive total amount!")
				return
			
			return
	
	# the assumption that the item "itemId" exists in the container "containerId" was violated!
	print("inventoryLedge: assumption violated: existing combination of itemId and containerId!")
	return


