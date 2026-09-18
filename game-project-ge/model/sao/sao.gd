extends Node

func _process(_delta):
	if EventScheduler.fuseCheck:
		turn_on_all_lights()


func turn_on_all_lights():
	$SpotLight3D.visible = true
