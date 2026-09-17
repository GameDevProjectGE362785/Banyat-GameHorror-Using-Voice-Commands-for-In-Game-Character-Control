extends StaticBody3D

class_name itemClass

func getInteractive() -> String:
	return "null"

func get_item_name() -> String:
	return "Item"


func removeItem():
	self.queue_free()
