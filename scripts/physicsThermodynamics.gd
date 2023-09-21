extends Node

class_name physicsThermodynamics

# compute how much a material is heated (in Kelvin) based on received energy (in joules) and mass (in kilograms)
static func calcHeatingByEnergy(energy, specificHeatCapacity, mass):
	return energy / (specificHeatCapacity*mass)
