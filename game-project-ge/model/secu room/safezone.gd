extends Area3D


func _on_body_entered(body):
	if body.is_in_group("Player"):
		EventScheduler.SaveZone = true
		print("มีคนอยู่ในห้องพัก")


func _on_body_exited(body):
	if body.is_in_group("Player"):
		EventScheduler.SaveZone = false
		print("ไม่มีคนอยู่ในห้องพัก")
