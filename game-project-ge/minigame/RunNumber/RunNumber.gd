extends Control

@onready var status_label: Label = $VBox/StatusLabel
@onready var buttons_container: HBoxContainer = $VBox/ButtonsContainer
@onready var restart_button: Button = $VBox/RestartButton

var buttons: Array[Button] = []
var sequence: Array[int] = []
var player_index: int = 0
var accepting_input: bool = false
var round_busy: bool = false

const HIGHLIGHT_COLOR := Color(1.0, 0.85, 0.1)
const CORRECT_COLOR := Color(0.3, 0.85, 0.3)
const WRONG_COLOR := Color(0.9, 0.2, 0.2)
const NORMAL_COLOR := Color(1, 1, 1)

const SHOW_TIME := 0.6
const GAP_TIME := 0.3


func _ready() -> void:
	for child in buttons_container.get_children():
		if child is Button:
			buttons.append(child)

	for i in buttons.size():
		buttons[i].pressed.connect(_on_button_pressed.bind(i))

	restart_button.pressed.connect(_start_round)
	restart_button.visible = false

	_start_round()


func _start_round() -> void:
	if round_busy:
		return
	round_busy = true
	restart_button.visible = false
	accepting_input = false
	player_index = 0
	_reset_button_colors()
	_set_buttons_disabled(true)

	sequence = _make_shuffled_sequence(buttons.size())

	status_label.text = "ดูลำดับให้ดี..."
	await get_tree().create_timer(0.6).timeout
	await _play_sequence()

	status_label.text = "กดตามลำดับที่จำได้"
	accepting_input = true
	round_busy = false
	_set_buttons_disabled(false)


func _make_shuffled_sequence(n: int) -> Array[int]:
	var arr: Array[int] = []
	for i in n:
		arr.append(i)
	arr.shuffle()
	return arr


func _play_sequence() -> void:
	for idx in sequence:
		buttons[idx].modulate = HIGHLIGHT_COLOR
		await get_tree().create_timer(SHOW_TIME).timeout
		buttons[idx].modulate = NORMAL_COLOR
		await get_tree().create_timer(GAP_TIME).timeout


func _on_button_pressed(idx: int) -> void:
	if not accepting_input:
		return

	if idx == sequence[player_index]:
		accepting_input = false
		buttons[idx].modulate = CORRECT_COLOR
		await get_tree().create_timer(0.2).timeout
		buttons[idx].modulate = NORMAL_COLOR
		player_index += 1

		if player_index >= sequence.size():
			_set_buttons_disabled(true)
			status_label.text = "ถูกต้องทั้งหมด! เยี่ยมมาก 🎉"
			restart_button.visible = true
		else:
			accepting_input = true
	else:
		accepting_input = false
		_set_buttons_disabled(true)
		buttons[idx].modulate = WRONG_COLOR
		status_label.text = "กดผิดลำดับ! แพ้ - กด \"เริ่มใหม่\" เพื่อลองอีกครั้ง"
		restart_button.visible = true
		await get_tree().create_timer(0.4).timeout
		buttons[idx].modulate = NORMAL_COLOR


func _set_buttons_disabled(v: bool) -> void:
	for b in buttons:
		b.disabled = v


func _reset_button_colors() -> void:
	for b in buttons:
		b.modulate = NORMAL_COLOR
