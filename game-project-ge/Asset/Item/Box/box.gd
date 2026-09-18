extends "res://Asset/ClassItem.gd"

class_name Box

func getInteractive() -> String:
	return "Check The Box"

func get_item_name() -> String:
	return "Box"
func disable_collision():
	$CollisionShape3D.disabled = true
