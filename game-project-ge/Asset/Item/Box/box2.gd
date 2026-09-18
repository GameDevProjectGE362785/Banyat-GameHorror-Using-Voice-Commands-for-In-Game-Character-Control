extends "res://Asset/ClassItem.gd"


class_name Box2

func getInteractive() -> String:
	return "Check The Box"

func get_item_name() -> String:
	return "Box2"
func disable_collision():
	$CollisionShape3D.disabled = true
