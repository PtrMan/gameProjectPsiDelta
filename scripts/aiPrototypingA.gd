# AI thingy

extends Resource

#@export var currentState: String = ""


# idea: behaviour tree for behaviour of AI
# return "continue", "success", "failure"

class BtSeq:
	func new(children):
		self.children = children
		reset()
		
	# /param propagate: string or null, is the result from the last called behaviour
	func tick(deltaTime: float, propagate) -> String:
		var calledResult: String = self.children[self.currentIdx].tick(deltaTime, propagate)
		if calledResult == "success":
			self.currentIdx+=1
			
			if self.currentIdx >= self.children.size():
				return "success"
			return "continue"
		if calledResult == "continue":
			return "continue"
		else: # "failure"
			# propagate failure
			return "failure"
	
	func reset():
		self.currentIdx = 0
	
	func notifySignal(signalName: String, signalData):
		pass

class BtSel:
	func new(children):
		self.children = children
		reset()
	
	# /param propagate: string or null, is the result from the last called behaviour
	func tick(deltaTime: float, propagate) -> String:
		if self.currentIdx >= self.children.size():
			return "failure"
		
		var calledResult: String = self.children[self.currentIdx].tick(deltaTime, propagate)
		if calledResult == "success":
			reset()
			return "success"
		elif calledResult == "continue":
			return "continue"
		else: # "failure":
			# select next
			self.currentIdx += 1
			return "continue"
		
	
	func reset():
		self.currentIdx = 0
	
	func notifySignal(signalName: String, signalData):
		pass


class BtDelay:
	func new(restartTime: float):
		self.restartTime = restartTime
		reset()
		
	# /param propagate: string or null, is the result from the last called behaviour
	func tick(deltaTime: float, propagate) -> String:
		self.timeCounter += deltaTime
		if self.timeCounter >= 0.0:
			return "success" # we waited for the time so we return success
		return "continue"
	
	func reset():
		self.timeCounter = -self.restartTime
	
	func notifySignal(signalName: String, signalData):
		pass


# TODO< add GotoA behaviour, which wait until the vehicle got to the destination >
class BtGotoA:
	func new(selfVehicleName, signalData):
		self.selfVehicleName = selfVehicleName
		self.signalData = signalData
		reset()
		
	# /param propagate: string or null, is the result from the last called behaviour
	func tick(deltaTime: float, propagate) -> String:
		if self.state == 0:
			# send instruction to begin moving of vehicle
			# TODO< send instruction to THING to cause vehicle "selfVehicleName" to move >
			print("TODO - send instruction to move")
			
			self.state = 1
			return "continue"
		
		elif self.state == 1:
			return "continue"
		elif self.state == 2:
			self.state = 3 # set state so that we return error on next visit, because a error occurred, we expected that the signal will get reset
			return "success"
		
		else:
			# we arived here again after cofirming the signal, this is a error somewhere
			return "failure"
	
	func reset():
		# 0 : enter
		# 1 : sent instruction to begin move
		# 2 : received signal
		# 3 : propagated signal
		self.state = 0
	
	func notifySignal(signalName: String, signalData):
		if signalName == "arrival" and self.signalData == self.selfVehicleName:
			self.state = 2



var rootElement

var callStack = []
var resToPropagateDown = null

# called when ever the AI gets compute resources
func tick(deltaTime: float):
	callStack = [rootElement]
	resToPropagateDown = null
	
	
	
	
	var currentElement = callStack[callStack.size()-1]
	var res: String = currentElement.tick(deltaTime, resToPropagateDown)
	resToPropagateDown = null
	if res == "continue":
		pass
	if res == "success":
		callStack.pop_back()
	if res == "failure":
		resToPropagateDown = "failure"
	
	
	if resToPropagateDown == "failure":
		# handle failure
		
		pass
		# TODO
	
	
	
	
	#if currentElement is BtDelay:
	#	if currentElement.timeCounter >= 0.0: # time counter is passed
	#		pass
	
	#pass
	
	#if currentState == "":
	#	pass
	#
	#if currentState == "moveTo_waitArrived":
	#	# we wait for arrival signal in this state
	#	
	#	if lastSignals.size() > 0 and lastSignals[0] == "arrived":
	#		currentState = ""



