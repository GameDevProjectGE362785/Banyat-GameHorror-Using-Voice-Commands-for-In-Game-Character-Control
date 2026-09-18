extends Button

## ลาก scene มาใส่ใน Inspector ได้ หรือจะ hardcode path ก็ได้
@export var next_scene: PackedScene

## ถ้าอยากให้ซ่อนทั้งหน้า UI (ไม่ใช่แค่ปุ่ม) ลาก node แม่ของ UI มาใส่
@export var ui_to_hide: CanvasItem


func _ready() -> void:
	# เชื่อม signal ตอนกดปุ่ม
	pressed.connect(_on_pressed)


func _on_pressed() -> void:
	# ป้องกันกดซ้ำระหว่างรอเปลี่ยน scene
	disabled = true
	
	# ซ่อน UI ก่อน (ถ้ากำหนดไว้) ไม่ใช่ queue_free เพราะ node กำลังถูกใช้งาน
	if ui_to_hide:
		ui_to_hide.hide()
	else:
		hide()
	
	# เปลี่ยน scene — วิธีนี้จะจัดการ scene เก่าให้เอง ไม่ต้อง instantiate มือ
	if next_scene:
		GameClock.Start = true
		get_tree().change_scene_to_packed(next_scene)
	else:
		GameClock.Start = true
		get_tree().change_scene_to_file("res://scenes/Intro.tscn")
