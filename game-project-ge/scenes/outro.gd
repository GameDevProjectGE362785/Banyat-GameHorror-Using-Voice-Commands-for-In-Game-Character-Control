extends Control
@export_multiline var full_text: String = "ยินดีด้วยคุณทำภารกิจทั้งหมดเสร็จแล้ว\nยอดเยี่ยมมาก\nคุณอาจจะเจออะไรที่รู้สึกแปลกๆไปบ้าง\nแต่น้้นคือการคิดไปเอง\nเดี๊ยวเราจะทำการโอนเงินเข้าบัญชีของคุณ\nชาติหน้าตอนบ่ายๆ\nเจอกันไอ้โง่งานฟรีสนุกไหม"
@export var chars_per_second: float = 20.0
@export var next_scene_path: String = "res://Main/MainMenuUI.tscn"

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
	if next_scene_path != "":
		get_tree().change_scene_to_file(next_scene_path)
