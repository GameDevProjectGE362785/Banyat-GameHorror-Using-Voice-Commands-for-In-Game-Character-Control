extends Control
@export_multiline var full_text: String = "ด่วน\nประกาศรับสมัครงาน งานดีเงินดี วัน1000000บาท\nรับสมัครยามกะดึกทำงานเวลาเทียงคืนถึงหกโมงเช้า\nไม่คัดคุณสมบัติ ไม่จำกัดวุฒิการศึกษา\nช้าหมดอดนะจ้ะ"
@export var chars_per_second: float = 20.0
@export var next_scene_path: String = "res://Main/main.tscn"

var _char_index: int = 0
var _time_accum: float = 0.0
var _finished_typing: bool = false

func _ready() -> void:
	$StoryText.text = "ด่วนๆ"

func _process(delta: float) -> void:
	if _finished_typing:
		return
	_time_accum += delta
	var chars_to_show := int(_time_accum * chars_per_second)
	if chars_to_show != _char_index:
		_char_index = chars_to_show
		if _char_index >= full_text.length():
			_char_index = full_text.length()
			_finished_typing = true
		$StoryText.text = full_text.substr(0, _char_index)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_select") or (event is InputEventKey and event.pressed):
		if not _finished_typing:
			_char_index = full_text.length()
			_finished_typing = true
			$StoryText.text = full_text
			$AudioStreamPlayer.stop()
		else:
			_finish_intro()

func _finish_intro() -> void:
	$Button.visible = true
	$Button2.visible = true



func _on_button_pressed() -> void:
	get_tree().change_scene_to_file(next_scene_path)
	pass # Replace with function body.


func _on_button_2_pressed() -> void:
	get_tree().change_scene_to_file("res://Main/MainMenuUI.tscn")
	pass # Replace with function body.
