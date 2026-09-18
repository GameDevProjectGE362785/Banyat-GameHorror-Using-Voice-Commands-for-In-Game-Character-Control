extends Area3D

@export var door

## กำหนดว่าจะเช็คบ่อยแค่ไหน (วินาทีต่อครั้ง)
@export var check_interval: float = 4

## กำหนดโอกาสที่ action จะเกิด (สุ่ม 1-10 ถ้ามากกว่าค่านี้ = เกิด)
@export var trigger_threshold: int = 7

## ตัวแปรเก็บว่ามีตัวละครอยู่ใน area หรือไม่
var character_in_area: bool = false

## ตัวแปรกันการสุ่มซ้ำซ้อนระหว่างรอบเช็ค
var _timer: float = 0.0


func _ready() -> void:
	# เชื่อมสัญญาณเมื่อมี object เข้า/ออกจาก area
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _process(delta: float) -> void:
	# ถ้าไม่มีตัวละครอยู่ใน area ก็ไม่ต้องทำอะไร
	if not character_in_area:
		return
	
	# นับเวลาตามช่วงที่กำหนด
	_timer += delta
	if _timer >= check_interval:
		_timer = 0.0
		roll_action()


## ฟังก์ชันสุ่มตัวเลข 1-10
func roll_action() -> void:
	var roll: int = randi_range(1, 10)
	print("สุ่มได้: ", roll)
	
	# ถ้าสุ่มได้มากกว่า threshold (ค่าเริ่มต้นคือ 7) ให้เกิด action
	if roll > trigger_threshold:
		trigger_action()


## ⚠️ เว้นไว้ให้คุณต่อยอด — ใส่ logic ของ action ที่นี่
func trigger_action() -> void:
	print("Action ถูกกระตุ้น! (มาต่อยอดตรงนี้)")
	pass


# ---------- Signal Handlers ----------

func _on_body_entered(body: Node3D) -> void:
	# ตรวจสอบว่า body ที่เข้ามาคือตัวละครหรือไม่
	# (แนะนำให้ตัวละครมี group ชื่อ "player" หรือใช้การเช็ค class แทน)
	if body.is_in_group("player"):
		character_in_area = true
		print("ตัวละครเข้ามาใน area แล้ว")


func _on_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		character_in_area = false
		print("ตัวละครออกจาก area แล้ว")
