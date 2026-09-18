extends itemClass
class_name doorClass

# --- Tunables (edit in the Inspector) ---
@export var open_angle_deg: float = 90.0
@export var open_duration: float = 0.5
@export var invert_swing: bool = false  # flip this if it opens the wrong way in testing

@onready var audioPlay = $AudioStreamPlayer3D

var is_open: bool = false
var is_animating: bool = false

var closed_rotation_y: float
var target_rotation_y: float

var tween: Tween

func _ready() -> void:
	closed_rotation_y = rotation.y
	target_rotation_y = closed_rotation_y


func get_item_name() -> String:
	return "Door"


func getInteractive() -> String:
	if is_open:
		return "Press F to close door "
	else:
		return "Press F to open door / Press K to Knock"


func interactive() -> void:
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
	if invert_swing:
		side = -side

	var angle: float = deg_to_rad(open_angle_deg)

	# Player in front (side > 0) -> swing away from them (negative direction).
	# Player behind (side <= 0) -> swing the other way.
	if side > 0.0:
		target_rotation_y = closed_rotation_y - angle
	else:
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
	
func randomEvent():
	audioPlay.play()
	if is_open:
		print("Death")
	
