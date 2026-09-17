extends Node3D

class_name ItemEvent

#func changeOpacity(type : String):
	#self.transform.o


func getInteractive() -> String:
	return "null"

func get_item_name() -> String:
	return "Item"
	
func interactive():
	self.queue_free()
