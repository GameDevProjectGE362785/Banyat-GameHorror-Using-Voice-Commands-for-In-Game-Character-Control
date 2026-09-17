extends Control

const LEVER_COUNT := 4

@onready var status_label: Label = $VBox/StatusLabel
@onready var levers_container: HBoxContainer = $VBox/LeversContainer
@onready var test_button: Button = $VBox/TestButton
@onready var restart_button: Button = $VBox/RestartButton
@onready var Exit_buttonn: Button = $ExitButton

var secret: Array[bool] = []
var lever_state: Array[bool] = []
var lever_buttons: Array[Button] = []

var attempts: int = 0
var solved: bool = false


func _ready() -> void:
	test_button.pressed.connect(_on_test_pressed)
	restart_button.pressed.connect(_start_game)
	Exit_buttonn.pressed.connect(endgame)

	restart_button.visible = false

	# =====================================================
	# ถ้าทำมินิเกมนี้เสร็จไปแล้ว
	# ห้ามเล่นซ้ำ
	# =====================================================
	if EventScheduler.CutOut:
		_close_minigame()
		return

	_start_game()


func _start_game() -> void:
	# =====================================================
	# ป้องกันการเริ่มเกมซ้ำหลังทำเสร็จ
	# =====================================================
	if EventScheduler.CutOut:
		_close_minigame()
		return

	solved = false
	attempts = 0

	restart_button.visible = false
	test_button.disabled = false

	status_label.text = "คันโยกแต่ละตัวต้องสับซ้าย (L) หรือขวา (R) ต่างกันไป — คลิกที่คันโยกเพื่อสลับ แล้วกด \"ทดสอบระบบ\""

	secret.clear()
	lever_state.clear()

	# สุ่มคำตอบ
	for i in LEVER_COUNT:
		secret.append(randi() % 2 == 1)
		lever_state.append(false)

	# ลบปุ่มเก่า
	for c in levers_container.get_children():
		c.queue_free()

	lever_buttons.clear()

	# สร้างปุ่มคันโยก
	for i in LEVER_COUNT:
		var btn := _make_lever_button(i)
		levers_container.add_child(btn)
		lever_buttons.append(btn)


func _make_lever_button(idx: int) -> Button:
	var btn := Button.new()

	btn.custom_minimum_size = Vector2(92, 120)
	btn.focus_mode = Control.FOCUS_NONE

	btn.pressed.connect(_on_lever_pressed.bind(idx))

	_update_lever_visual(btn, idx)

	return btn


func _on_lever_pressed(idx: int) -> void:
	if solved:
		return

	# ป้องกันเล่นซ้ำ
	if EventScheduler.CutOut:
		_close_minigame()
		return

	lever_state[idx] = not lever_state[idx]

	_update_lever_visual(lever_buttons[idx], idx)


func _update_lever_visual(btn: Button, idx: int) -> void:
	var is_right: bool = lever_state[idx]

	var arrow := "→" if is_right else "←"
	var side_text := "ขวา (R)" if is_right else "ซ้าย (L)"

	btn.text = "คันโยก %d\n\n%s\n%s" % [
		idx + 1,
		arrow,
		side_text
	]

	btn.add_theme_font_size_override("font_size", 14)

	var sb := StyleBoxFlat.new()

	sb.bg_color = (
		Color(0.95, 0.72, 0.32)
		if is_right
		else Color(0.42, 0.62, 0.95)
	)

	sb.corner_radius_top_left = 10
	sb.corner_radius_top_right = 10
	sb.corner_radius_bottom_left = 10
	sb.corner_radius_bottom_right = 10

	btn.add_theme_stylebox_override("normal", sb)
	btn.add_theme_stylebox_override("hover", sb)
	btn.add_theme_stylebox_override("pressed", sb)
	btn.add_theme_stylebox_override("focus", sb)


func _on_test_pressed() -> void:
	if solved:
		return

	# ป้องกันเล่นซ้ำ
	if EventScheduler.CutOut:
		_close_minigame()
		return

	attempts += 1

	var correct_count := 0

	for i in LEVER_COUNT:
		if lever_state[i] == secret[i]:
			correct_count += 1

	# =====================================================
	# ถูกทั้งหมด
	# =====================================================
	if correct_count == LEVER_COUNT:

		solved = true

		test_button.disabled = true

		# บันทึกว่าทำมินิเกมนี้เสร็จแล้ว
		EventScheduler.CutOut = true

		status_label.text = "ระบบไฟฟ้าถูกปิดเรียบร้อย ✅"

		print("Lever Minigame Passed")
		print("CutOut = ", EventScheduler.CutOut)

		# ปิดคันโยก
		for btn in lever_buttons:
			btn.disabled = true

		# รอ 3 วินาที
		await get_tree().create_timer(3.0).timeout

		_close_minigame()

	# =====================================================
	# ยังไม่ถูก
	# =====================================================
	else:
		status_label.text = "ยังไม่ถูกต้อง — ถูก %d / %d ตัว (ครั้งที่ %d) ลองปรับคันโยกแล้วกดทดสอบอีกครั้ง" % [
			correct_count,
			LEVER_COUNT,
			attempts
		]


# =========================================================
# ปุ่ม Exit
# =========================================================
func endgame() -> void:
	visible = false

	# FPS Mode
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


# =========================================================
# ปิด Minigame
# =========================================================
func _close_minigame() -> void:
	solved = true

	test_button.disabled = true
	restart_button.visible = false

	for btn in lever_buttons:
		btn.disabled = true

	# ปิดการมองเห็นมินิเกม
	visible = false

	# กลับเป็น FPS Mode
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
