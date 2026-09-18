extends ClassItem
class_name doorContainer

# --- Tunables (edit in the Inspector) ---
@export var open_angle_deg: float = 90.0
@export var open_duration: float = 0.5
@export var invert_swing: bool = false  # flip this if it opens the wrong way in testing

@export var NumberDoor = 0

var is_open: bool = false
var is_animating: bool = false

var closed_rotation_y: float
var target_rotation_y: float

var tween: Tween

#From Inside
var lock = false

# =========================================================
# ตรวจจับการเปลี่ยนสถานะล็อก (poll ทุกเฟรม เพราะ EventScheduler
# เก็บเป็น bool ธรรมดา ไม่มี signal แจ้งตอนเปลี่ยนค่า)
# =========================================================
var _was_locked: bool = false


func _ready() -> void:
	closed_rotation_y = rotation.y
	target_rotation_y = closed_rotation_y

	# เก็บสถานะล็อกตอนเริ่มไว้ก่อน กันไม่ให้ตีความว่า "เพิ่งล็อก" ตอนเริ่มเกม
	_was_locked = _get_lock_status()


func _process(_delta: float) -> void:
	var locked_now: bool = _get_lock_status()

	# =====================================================
	# เพิ่งถูกล็อก (false -> true) -> ปิดประตูเองถ้าเปิดอยู่
	# =====================================================
	if locked_now and not _was_locked:
		print("ประตู ", NumberDoor, " ถูกล็อก -> ปิดประตูอัตโนมัติ")
		if is_open and not is_animating:
			_close_door()

	_was_locked = locked_now


func _get_lock_status() -> bool:
	var value = EventScheduler.get("door_locked" + str(NumberDoor))

	if value == null:
		push_warning("doorContainer: ไม่พบ 'doorlock%s' ใน EventScheduler (เช็คว่า NumberDoor ตั้งถูกไหม)" % str(NumberDoor))
		return false

	return value


func get_item_name() -> String:
	return "DoorContainer"


func getInteractive() -> String:
	if is_open:
		return "Press F to close door "
	else:
		return "Press F to open door / Press K to Knock"


func interactive() -> void:
	if !_get_lock_status():
		if is_animating:
			return
		if is_open:
			_close_door()
		else:
			_open_door()


func _open_door() -> void:
	var player := get_tree().get_first_node_in_group("player")
	if player == null:
		push_warning("doorClass: no node found in group 'player'. Add your player to a group named 'player'.")
		return

	var to_player: Vector3 = player.global_position - global_position
	to_player.y = 0.0

	# "Facing" direction of the door when closed — the plane normal we use
	# to decide which side the player is standing on.
	var door_facing: Vector3 = global_transform.basis.z
	door_facing.y = 0.0

	var side: float = door_facing.normalized().dot(to_player.normalized())

	var angle: float = deg_to_rad(open_angle_deg)

	target_rotation_y = closed_rotation_y + angle

	is_open = true
	_animate_to(target_rotation_y)


func _close_door() -> void:
	is_open = false
	_animate_to(closed_rotation_y)


func _animate_to(target_y: float) -> void:
	is_animating = true
	if tween:
		tween.kill()
	tween = create_tween()
	tween.tween_property(self, "rotation:y", target_y, open_duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.finished.connect(func(): is_animating = false)
	
func getLockStatus():
	return lock
