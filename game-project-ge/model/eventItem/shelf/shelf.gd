extends "res://Asset/ClassItem.gd"

class_name Shelf


func getInteractive() -> String:
	return "work"

func get_item_name() -> String:
	return "Shelf"

func interactive():
	$Main.visible = true
	

	
