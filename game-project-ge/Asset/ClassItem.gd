extends StaticBody3D

class_name ClassItem

#func changeOpacity(type : String):
	#self.transform.o


func getInteractive() -> String:
	return "null"

func get_item_name() -> String:
	return "Item"
	
func interactive():
	self.queue_free()
