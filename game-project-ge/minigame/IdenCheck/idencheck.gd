extends Control

const TOTAL_ROUNDS: int = 5

@export var min_speed: float = 180.0
@export var max_speed: float = 420.0
@export var success_zone_width: float = 90.0

@onready var status_label: Label = $VBox/StatusLabel
@onready var progress_label: Label = $VBox/ProgressLabel
@onready var bar: ColorRect = $VBox/Bar
@onready var success_zone: ColorRect = $VBox/Bar/SuccessZone
@onready var pointer: ColorRect = $VBox/Bar/Pointer
@onready var check_button: Button = $VBox/CheckButton
@onready var Exiit: Button = $Exit

var current_round: int = 0
var pointer_x: float = 0.0
var direction: float = 1.0
var speed: float = 250.0
var event_running: bool = false


func _ready() -> void:
	randomize()

	check_button.pressed.connect(_on_check_pressed)
	Exiit.pressed.connect(stop)

	hide()
	event_running = false


func _process(delta: float) -> void:
	if not event_running:
		return

	pointer_x += speed * direction * delta

	var max_x: float = bar.size.x - pointer.size.x

	if pointer_x >= max_x:
		pointer_x = max_x
		direction = -1.0

	elif pointer_x <= 0.0:
		pointer_x = 0.0
		direction = 1.0

	pointer.position.x = pointer_x


func open_event() -> void:
	if EventScheduler.Fix:
		status_label.text = "ผ่านการทดสอบนี้แล้ว"
		progress_label.text = "ตรวจสอบสำเร็จแล้ว"
		check_button.disabled = true
		event_running = false
		show()

		await get_tree().create_timer(3.0).timeout

		visible = false
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		return

	show()

	current_round = 0
	event_running = true
	check_button.disabled = false

	next_round()


func stop() -> void:
	event_running = false
	visible = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func close_event() -> void:
	event_running = false
	hide()


func next_round() -> void:
	if EventScheduler.Fix:
		_finish_as_already_passed()
		return

	current_round += 1

	if current_round > TOTAL_ROUNDS:
		success_event()
		return

	speed = randf_range(min_speed, max_speed)

	var max_zone_x: float = bar.size.x - success_zone_width
	var zone_x: float = randf_range(0.0, max_zone_x)

	success_zone.position.x = zone_x
	success_zone.size.x = success_zone_width

	pointer_x = 0.0

	if randf() > 0.5:
		direction = 1.0
	else:
		direction = -1.0

	pointer.position.x = pointer_x

	progress_label.text = "ตรวจสอบ %d / %d" % [
		current_round,
		TOTAL_ROUNDS
	]

	status_label.text = "กดตรวจสอบตอนตัวชี้อยู่ในช่อง!"


func _input(event: InputEvent) -> void:
	if not event_running:
		return

	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_SPACE:
			_on_check_pressed()


func _on_check_pressed() -> void:
	if EventScheduler.Fix:
		_finish_as_already_passed()
		return

	if not event_running:
		return

	var pointer_left: float = pointer.global_position.x
	var pointer_right: float = pointer.global_position.x + pointer.size.x

	var zone_left: float = success_zone.global_position.x
	var zone_right: float = success_zone.global_position.x + success_zone.size.x

	var success: bool = (
		pointer_right >= zone_left
		and pointer_left <= zone_right
	)

	print("==============================")
	print("CHECK")
	print("Pointer : %.1f -> %.1f" % [pointer_left, pointer_right])
	print("Zone    : %.1f -> %.1f" % [zone_left, zone_right])
	print("RESULT  : %s" % ("SUCCESS" if success else "FAIL"))
	print("==============================")

	if success:
		status_label.text = "ถูกต้อง!"
		check_button.disabled = true

		await get_tree().create_timer(0.4).timeout

		if not event_running:
			return

		if EventScheduler.Fix:
			_finish_as_already_passed()
			return

		check_button.disabled = false
		next_round()

	else:
		fail_event()


func success_event() -> void:
	event_running = false
	check_button.disabled = true

	status_label.text = "ตรวจสอบสำเร็จ!"
	progress_label.text = "ครบ %d / %d ครั้ง" % [
		TOTAL_ROUNDS,
		TOTAL_ROUNDS
	]

	EventScheduler.Fix = true

	print("==============================")
	print("CHECK EVENT SUCCESS")
	print("EventScheduler.Fix = ", EventScheduler.Fix)
	print("==============================")

	await get_tree().create_timer(3.0).timeout

	visible = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func fail_event() -> void:
	event_running = false
	check_button.disabled = true
	await get_tree().create_timer(3).timeout 
	status_label.text = "ตรวจสอบไม่สำเร็จ!"
	open_event()
	print("==============================")
	print("CHECK EVENT FAILED")
	print("พลาดรอบ %d / %d" % [
		current_round,
		TOTAL_ROUNDS
	])
	print("==============================")


func _finish_as_already_passed() -> void:
	event_running = false
	check_button.disabled = true

	status_label.text = "ผ่านการทดสอบนี้แล้ว"
	progress_label.text = "ตรวจสอบสำเร็จแล้ว"

	await get_tree().create_timer(3.0).timeout

	visible = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func toggle_event() -> void:
	if event_running:
		close_event()
	else:
		open_event()
