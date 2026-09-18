extends Area3D


func _on_body_entered(body):
	if body.is_in_group("Player"):
		EventScheduler.CharacinGodang2 = true
		print("มีคนอยู่ในโกดัง2")


func _on_body_exited(body):
	if body.is_in_group("Player"):
		EventScheduler.CharacinGodang2 = false
		print("ไม่มีคนอยู่ในโกดัง2")
