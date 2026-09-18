extends Button


func _on_pressed() -> void:
	# ป้องกันกดซ้ำระหว่างรอเปลี่ยน scene
	get_tree().free()
