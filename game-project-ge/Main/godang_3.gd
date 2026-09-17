extends Area3D


func _on_body_entered(body):
	if body.is_in_group("Player"):
		EventScheduler.CharacinGodang3 = true
		print("มีคนอยู่ในโกดัง3")


func _on_body_exited(body):
	if body.is_in_group("Player"):
		EventScheduler.CharacinGodang3 = false
		print("ไม่มีคนอยู่ในโกดัง3")
