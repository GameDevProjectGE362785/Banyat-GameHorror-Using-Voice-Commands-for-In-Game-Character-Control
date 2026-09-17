extends "res://Asset/ItemClass.gd"

class_name Wrench

@onready var wrench = $Sketchfab_Scene
@onready var mesh = $MeshInstance3D

var ontable = true

func getInteractive() -> String:
	if ontable:
		return "Grab Wrench"
	else:
		return "Place Item"

func get_item_name() -> String:
	return "Wrench"

func getOnTable():
	return ontable

func interactive():
	ontable = !ontable
	if ontable:
		wrench.visible = true
		mesh.visible = false
	else:
		wrench.visible = false
		mesh.visible = true
