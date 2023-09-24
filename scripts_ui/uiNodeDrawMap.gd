# node which displays the map of the solar system

extends Control

# center of map
@export var mapCenter3d: Vector3 = Vector3(0.0, 0.0, 0.0)

@export var offset2d: Vector2 = Vector2(50.0, 50.0)

@export var scaleFactor: float = 1.0e-4 * 5.0 # scale factor from meters to units

var assetButtonWhiteCircle = preload("res://elementScenes_ui/buttonWhiteCircle.tscn")

var frameCnt: int = 0

func _process(delta):
	# HACKY
	frameCnt+=1
	if (frameCnt % 20) != 0:
		return
	
	
	queue_redraw() # force redraw
	
	utils.clearChildren(self)
	
	for iCelestial in celestialManager.celestials:
		var center3d: Vector3
		var center2d: Vector2
		
		center3d = (iCelestial.position-mapCenter3d)*scaleFactor
		center2d = Vector2(center3d.x, -center3d.z)+offset2d
		
		var nodeWhiteButton = assetButtonWhiteCircle.instantiate()
		nodeWhiteButton.position = center2d + Vector2(-8, -8)
		nodeWhiteButton.connect("button_up", _on_buttonUp_celestial.bind(["celestial", iCelestial.id]))
		self.add_child(nodeWhiteButton)


func _draw():
	var orbitUiArcWidth: float = 2.0
	
	for iCelestial in celestialManager.celestials:
		var center3d: Vector3
		var center2d: Vector2
		
		if iCelestial.piviotId != -1:
			center3d = (celestialManager.retPositionByPiviotId(iCelestial.piviotId)-mapCenter3d)*scaleFactor
			center2d = Vector2(center3d.x, -center3d.z)+offset2d
			var radius: float = max(iCelestial.orbitRadiusA*scaleFactor, iCelestial.orbitRadiusB*scaleFactor) # HACKY
			draw_arc(center2d, radius, 0.0, PI*2.0, 180, Color(1.0, 1.0, 1.0), orbitUiArcWidth, true) # draw orbit
		
		#center3d = (iCelestial.position-mapCenter3d)*scaleFactor
		#center2d = Vector2(center3d.x, -center3d.z)+offset2d
		#draw_circle(center2d, 5.0, Color(0.0, 1.0, 0.0)) # planet position
	

# callback which is called when a celestial was clicked
func _on_buttonUp_celestial(arg0):
	$"..".selectedDestinationId = arg0
	
