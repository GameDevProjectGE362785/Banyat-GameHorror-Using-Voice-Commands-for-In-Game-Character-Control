extends "res://Asset/ItemEvent.gd"

class_name deckfolder

@onready var deckfolder = Node3D


func getInteractive() -> String:
	return "work"

func get_item_name() -> String:
	return "deckfolder"

func interactive():
	
	$Main.visibility_changed(true)
	
	
