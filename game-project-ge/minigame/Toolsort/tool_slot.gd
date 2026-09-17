extends PanelContainer

signal item_dropped(item: Control, slot: Control)

var correct_item_id: String = ""
var filled: bool = false

@onready var content: CenterContainer = $Inner/Content


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	reset_color()


func _can_drop_data(_pos: Vector2, data: Variant) -> bool:
	if filled:
		return false
	return typeof(data) == TYPE_DICTIONARY and data.has("item_id")


func _drop_data(_pos: Vector2, data: Variant) -> void:
	var source = data.get("source")
	if source == null:
		return
	item_dropped.emit(source, self)


func mark_correct() -> void:
	filled = true
	_set_bg_color(Color(0.30, 0.75, 0.35))


func flash_wrong() -> void:
	_set_bg_color(Color(0.85, 0.30, 0.30))
	await get_tree().create_timer(0.35).timeout
	if not filled:
		reset_color()


func reset_color() -> void:
	_set_bg_color(Color(0.90, 0.90, 0.90))


func _set_bg_color(c: Color) -> void:
	var sb := StyleBoxFlat.new()
	sb.bg_color = c
	sb.corner_radius_top_left = 10
	sb.corner_radius_top_right = 10
	sb.corner_radius_bottom_left = 10
	sb.corner_radius_bottom_right = 10
	sb.border_width_top = 2
	sb.border_width_bottom = 2
	sb.border_width_left = 2
	sb.border_width_right = 2
	sb.border_color = Color(0, 0, 0, 0.15)
	add_theme_stylebox_override("panel", sb)
