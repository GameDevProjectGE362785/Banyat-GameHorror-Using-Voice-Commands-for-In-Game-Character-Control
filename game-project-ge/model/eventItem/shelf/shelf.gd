extends "res://Asset/ItemClass.gd"

class_name Shelf


func getInteractive() -> String:
	return "work"

func get_item_name() -> String:
	return "Shelf"

func interactive():
	$Main.visible = true
	

	
