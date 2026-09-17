extends PanelContainer

var item_id: String = ""
var locked: bool = false


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(1, 1, 1)
	sb.corner_radius_top_left = 10
	sb.corner_radius_top_right = 10
	sb.corner_radius_bottom_left = 10
	sb.corner_radius_bottom_right = 10
	sb.border_width_top = 2
	sb.border_width_bottom = 2
	sb.border_width_left = 2
	sb.border_width_right = 2
	sb.border_color = Color(0, 0, 0, 0.2)
	add_theme_stylebox_override("panel", sb)


func _get_drag_data(_position: Vector2) -> Variant:
	if locked:
		return null
	var preview := duplicate()
	preview.modulate.a = 0.85
	set_drag_preview(preview)
	return {"item_id": item_id, "source": self}


func lock() -> void:
	locked = true
	mouse_default_cursor_shape = Control.CURSOR_ARROW
