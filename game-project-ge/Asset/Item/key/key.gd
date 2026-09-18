extends "res://Asset/ItemClass.gd"

class_name Key

@onready var key = $Sketchfab_Scene
@onready var mesh = $MeshInstance3D

var ontable = true

func getInteractive() -> String:
	if ontable:
		return "Grab key"
	else:
		return "Place Item"

func get_item_name() -> String:
	return "Key"

func getOnTable():
	return ontable

func interactive():
	ontable = !ontable
	if ontable:
		key.visible = true
		mesh.visible = false
	else:
		key.visible = false
		mesh.visible = true
