extends "res://Asset/ClassItem.gd"

class_name Workbench


func getInteractive() -> String:
	return "work"

func get_item_name() -> String:
	return "Workbench"

func interactive():
	$Main.visible = true
	

	
