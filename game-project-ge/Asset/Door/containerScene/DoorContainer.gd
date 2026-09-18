extends ClassItem
class_name doorContainer

# =========================================================
# Tunables (edit in Inspector)
# =========================================================
@export var open_angle_deg: float = 90.0
@export var open_duration: float = 0.5
@export var invert_swing: bool = false

@export var NumberDoor: int = 0
# =========================================================
# Auto Open หลังล็อกครบ 5 นาทีในเกม
# =========================================================
@export var auto_open_minutes: int = 5

var lock_start_game_minutes: int = -1
var auto_open_done: bool = false
# =========================================================
# Door State
# =========================================================
var is_open: bool = false
var is_animating: bool = false

var closed_rotation_y: float
var target_rotation_y: float

var tween: Tween

# From Inside
var lock = false

# =========================================================
# เสียงประตู
# =========================================================
@onready var door_sound: AudioStreamPlayer3D = $DoorSound

# =========================================================
# ใช้ตรวจจับว่า "เพิ่งล็อก"
# =========================================================
var _was_locked: bool = false


# =========================================================
# READY
# =========================================================
func _ready() -> void:
	closed_rotation_y = rotation.y
	target_rotation_y = closed_rotation_y

	# จำสถานะล็อกตอนเริ่มเกม
	_was_locked = _get_lock_status()


# =========================================================
# PROCESS
# =========================================================
func _process(_delta: float) -> void:
	var locked_now: bool = _get_lock_status()

	# =====================================================
	# ประตูเพิ่งถูกล็อก
	# =====================================================
	if locked_now and not _was_locked:
		print("========================================")
		print("DOOR LOCK")
		print("ประตูหมายเลข: ", NumberDoor)
		print("สถานะ: ถูกล็อก")
		print("เริ่มจับเวลา 5 นาทีในเกม")
		print("========================================")

		# บันทึกเวลาในเกมตอนเริ่มล็อก
		lock_start_game_minutes = (
			EventScheduler.current_hour * 60
			+ EventScheduler.current_minute
		)

		auto_open_done = false

		# หยุด Animation เดิม
		if tween:
			tween.kill()
			tween = null

		is_animating = false

		# ถ้าประตูเปิดอยู่ -> ปิด
		if is_open:
			_close_door()

	# =====================================================
	# ถ้าประตูยังล็อกอยู่ -> ตรวจเวลา
	# =====================================================
	if locked_now and lock_start_game_minutes >= 0 and not auto_open_done:
		var current_game_minutes := (
			EventScheduler.current_hour * 60
			+ EventScheduler.current_minute
		)

		var elapsed_minutes := current_game_minutes - lock_start_game_minutes

		# เผื่อเวลาข้าม 00:00
		if elapsed_minutes < 0:
			elapsed_minutes += 24 * 60

		if elapsed_minutes >= auto_open_minutes:
			auto_open_done = true

			print("========================================")
			print("DOOR AUTO OPEN")
			print("ประตูหมายเลข: ", NumberDoor)
			print("ล็อกครบ ", auto_open_minutes, " นาทีในเกม")
			print("กำลังปลดล็อกและเปิดประตู")
			print("========================================")

			# ปลดล็อก
			EventScheduler.set(
				"door_locked" + str(NumberDoor),
				false
			)

			# เปิดประตู
			_open_door()

			# รีเซ็ตเวลา
			lock_start_game_minutes = -1

	# =====================================================
	# อัปเดตสถานะล่าสุด
	# =====================================================
	_was_locked = locked_now

# =========================================================
# GET LOCK STATUS
# =========================================================
func _get_lock_status() -> bool:
	var property_name := "door_locked" + str(NumberDoor)

	var value = EventScheduler.get(property_name)

	if value == null:
		push_warning(
			"doorContainer: ไม่พบ '%s' ใน EventScheduler"
			% property_name
		)
		return false

	return bool(value)


# =========================================================
# ITEM NAME
# =========================================================
func get_item_name() -> String:
	return "DoorContainer"


# =========================================================
# INTERACTION TEXT
# =========================================================
func getInteractive() -> String:
	# ถ้าล็อกอยู่
	if _get_lock_status():
		return "Door Locked"

	# ถ้าเปิดอยู่
	if is_open:
		return "Press F to close door"

	# ถ้าปิดอยู่
	return "Press F to open door / Press K to Knock"


# =========================================================
# INTERACTIVE
# =========================================================
func interactive() -> void:
	# -----------------------------------------------------
	# ล็อกอยู่ -> ห้ามเปิด/ปิดด้วย F
	# -----------------------------------------------------
	if _get_lock_status():
		print(
			"DOOR ",
			NumberDoor,
			" | Locked -> ไม่สามารถเปิดประตูได้"
		)
		return

	# -----------------------------------------------------
	# ถ้ากำลัง Animation อยู่
	# -----------------------------------------------------
	if is_animating:
		return

	# -----------------------------------------------------
	# เปิด / ปิด
	# -----------------------------------------------------
	if is_open:
		_close_door()
	else:
		_open_door()


# =========================================================
# OPEN DOOR
# =========================================================
func _open_door() -> void:
	# เช็กล็อกอีกครั้งเพื่อความปลอดภัย
	if _get_lock_status():
		print(
			"DOOR ",
			NumberDoor,
			" | Locked -> เปิดไม่ได้"
		)
		return

	# -----------------------------------------------------
	# หา Player
	# -----------------------------------------------------
	var player := get_tree().get_first_node_in_group("player")

	if player == null:
		push_warning(
			"doorClass: no node found in group 'player'. "
			+ "Add your player to a group named 'player'."
		)
		return

	# -----------------------------------------------------
	# หาทิศทางผู้เล่น
	# -----------------------------------------------------
	var to_player: Vector3 = player.global_position - global_position
	to_player.y = 0.0

	var door_facing: Vector3 = global_transform.basis.z
	door_facing.y = 0.0

	if to_player.length() > 0.001:
		to_player = to_player.normalized()

	if door_facing.length() > 0.001:
		door_facing = door_facing.normalized()

	var side: float = door_facing.dot(to_player)

	# -----------------------------------------------------
	# คำนวณมุมเปิด
	# -----------------------------------------------------
	var angle: float = deg_to_rad(open_angle_deg)

	if invert_swing:
		angle = -angle

	target_rotation_y = closed_rotation_y + angle

	# -----------------------------------------------------
	# เปลี่ยนสถานะ
	# -----------------------------------------------------
	is_open = true

	print(
		"DOOR ",
		NumberDoor,
		" | เปิดประตู"
	)

	# -----------------------------------------------------
	# เล่นเสียง
	# -----------------------------------------------------
	_play_door_sound()

	# -----------------------------------------------------
	# Animation
	# -----------------------------------------------------
	_animate_to(target_rotation_y)


# =========================================================
# CLOSE DOOR
# =========================================================
func _close_door() -> void:
	# ถ้าปิดอยู่แล้ว ไม่ต้องทำอะไร
	if not is_open:
		return

	is_open = false

	print(
		"DOOR ",
		NumberDoor,
		" | ปิดประตู"
	)

	# เล่นเสียงปิด
	_play_door_sound()

	# Animation กลับตำแหน่งเดิม
	_animate_to(closed_rotation_y)


# =========================================================
# PLAY DOOR SOUND
# =========================================================
func _play_door_sound() -> void:
	if door_sound == null:
		push_warning(
			"DOOR ",
			NumberDoor,
			" | ไม่พบ DoorSound"
		)
		return

	# ถ้าเสียงเดิมกำลังเล่นอยู่
	if door_sound.playing:
		door_sound.stop()

	door_sound.play()


# =========================================================
# DOOR ANIMATION
# =========================================================
func _animate_to(target_y: float) -> void:
	is_animating = true

	# ลบ Tween เดิม
	if tween:
		tween.kill()
		tween = null

	# สร้าง Tween ใหม่
	tween = create_tween()

	tween.tween_property(
		self,
		"rotation:y",
		target_y,
		open_duration
	).set_trans(
		Tween.TRANS_SINE
	).set_ease(
		Tween.EASE_IN_OUT
	)

	# เมื่อ Animation เสร็จ
	tween.finished.connect(
		func():
			is_animating = false
			tween = null
	)
