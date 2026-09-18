extends Area3D
class_name CharacterTimerArea

## เวลาที่ต้องอยู่ใน area ก่อนจะสุ่ม (วินาที)
@export var trigger_time: float = 5.0

## Signal ที่จะถูกเรียกเมื่อสุ่มผ่านแล้ว action เกิด
signal action_triggered


var character_inside: bool = false
var _timer: float = 0.0


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _process(delta: float) -> void:
	# ไม่มีตัวละคร = หยุดนับ (pause ไม่ reset)
	if not character_inside:
		return
	
	_timer += delta
	
	if _timer >= trigger_time:
		_timer = 0.0
		_roll_action()


## สุ่มโอกาส 3/10 ที่จะเกิด action
func _roll_action() -> void:
	var roll: int = randi_range(1, 10)
	print("สุ่มได้: ", roll)
	
	if roll <= 3:
		action_triggered.emit()
		_do_action()


## ฟังก์ชัน action — มาต่อยอดตรงนี้
func _do_action() -> void:
	print("Action เกิดขึ้น!")
	pass


func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		character_inside = true


func _on_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		character_inside = false
