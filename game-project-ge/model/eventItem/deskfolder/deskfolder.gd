extends "res://Asset/ClassItem.gd"

class_name deckfolder


func getInteractive() -> String:
	return "work"

func get_item_name() -> String:
	return "deckfolder"

func interactive():
	$Main.visible = true
	

	
