extends CanvasLayer

@export var hints: Array[String] = [
	"ใช้ปุ่ม W A S D เพื่อเดิน",
	"กด F เพื่อหยิบ/ใช้ไอเท็ม",
	"กด M เพื่อเปิดแผนที่",
	"ในห้องพักมีกฎอยู่อย่าลืมอ่านด้วยละ",
	"และยังมีภารกิจที่ต้องทำ ลองกดTab เพื่อเช็คดูได้",
	"ไอเท็มต่างๆ จะอยู่ตามแมพต้องเดินหาเอา"   
]
@export var show_duration: float = 4.0   # ข้อความโชว์นานกี่วินาที
@export var gap_duration: float = 3.0    # เว้นก่อนขึ้นข้อความถัดไป
@export var fade_time: float = 0.4

var _index: int = 0

func _ready() -> void:
	$HUD/HintBox.modulate.a = 0.0
	_run_sequence()

func _run_sequence() -> void:
	while _index < hints.size():
		$HUD/HintBox/HintLabel.text = hints[_index]
		await _fade(1.0)
		await get_tree().create_timer(show_duration).timeout
		await _fade(0.0)
		await get_tree().create_timer(gap_duration).timeout
		_index += 1

func _fade(target_alpha: float) -> void:
	var tween := create_tween()
	tween.tween_property($HUD/HintBox, "modulate:a", target_alpha, fade_time)
	await tween.finished
