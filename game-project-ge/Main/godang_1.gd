extends Area3D


func _on_body_entered(body):
	if body.is_in_group("Player"):
		EventScheduler.CharacinGodang1 = true
		print("มีคนอยู่ในโกดัง1")


func _on_body_exited(body):
	if body.is_in_group("Player"):
		EventScheduler.CharacinGodang1 = false
		print("ไม่มีคนอยู่ในโกดัง1")
