extends Control

@onready var status_label: Label = $VBox/StatusLabel
@onready var history_label: Label = $VBox/HistoryLabel
@onready var grid: GridContainer = $VBox/Grid
@onready var restart_button: Button = $VBox/RestartButton

const GRID_COLUMNS := 4
const GRID_ROWS := 4
const TOTAL_ROUNDS := 3
const TILE_SIZE := Vector2(64, 64)
const TILE_GAP := 8
const CORNER_RADIUS := 8

# ความต่างของ "โทน" (ความสว่าง) ของช่องที่แตกต่าง ในแต่ละรอบ
# ยิ่งรอบหลังค่ายิ่งน้อย = สีใกล้เคียงกันมากขึ้น = ยากขึ้นเรื่อยๆ
const VALUE_DELTAS: Array[float] = [0.22, 0.15, 0.09]

var current_round: int = 0
var odd_index: int = -1
var accepting_input: bool = false
var history_lines: Array[String] = []
var tiles: Array[Button] = []


func _ready() -> void:
	grid.columns = GRID_COLUMNS
	grid.add_theme_constant_override("h_separation", TILE_GAP)
	grid.add_theme_constant_override("v_separation", TILE_GAP)
	restart_button.pressed.connect(_start_game)
	restart_button.visible = false
	_start_game()


func _start_game() -> void:
	current_round = 0
	history_lines.clear()
	restart_button.visible = false
	_update_history_label()
	_start_round()


func _start_round() -> void:
	current_round += 1
	accepting_input = false
	_clear_grid()

	var total_tiles := GRID_COLUMNS * GRID_ROWS
	odd_index = randi() % total_tiles

	var base_h := randf()
	var base_s := 0.62
	var base_v := 0.82
	var base_color := Color.from_hsv(base_h, base_s, base_v)

	var delta: float = VALUE_DELTAS[min(current_round - 1, VALUE_DELTAS.size() - 1)]
	var odd_v: float = clamp(base_v - delta, 0.05, 1.0)
	var odd_color := Color.from_hsv(base_h, base_s, odd_v)

	for i in total_tiles:
		var btn := Button.new()
		btn.custom_minimum_size = TILE_SIZE
		btn.focus_mode = Control.FOCUS_NONE
		_apply_tile_color(btn, base_color if i != odd_index else odd_color)
		btn.pressed.connect(_on_tile_pressed.bind(i))
		grid.add_child(btn)
		tiles.append(btn)

	status_label.text = "รอบ %d / %d — หาช่องที่สีต่างจากช่องอื่น" % [current_round, TOTAL_ROUNDS]
	accepting_input = true


func _clear_grid() -> void:
	for c in grid.get_children():
		grid.remove_child(c)
		c.queue_free()
	tiles.clear()


func _on_tile_pressed(idx: int) -> void:
	if not accepting_input:
		return
	accepting_input = false

	if idx == odd_index:
		history_label.text = "รอบ %d → ถูก ✓" % current_round

		_update_history_label()
		_apply_tile_color(tiles[idx], Color(0.3, 0.85, 0.3))
		await get_tree().create_timer(0.5).timeout

		if current_round >= TOTAL_ROUNDS:
			status_label.text = "สำเร็จ! 🎉 ผ่านครบทุกรอบแล้ว"
			history_lines.append("")
			history_lines.append("สำเร็จ!")
			_update_history_label()
			restart_button.visible = true
		else:
			_start_round()
	else:
		history_lines.append("รอบ %d → ผิด ✗ (แพ้)" % current_round)
		_update_history_label()
		_apply_tile_color(tiles[idx], Color(0.9, 0.2, 0.2))
		_apply_tile_color(tiles[odd_index], Color(0.3, 0.85, 0.3))
		status_label.text = "ผิด! ช่องสีเขียวคือช่องที่ถูกต้อง - กด \"เริ่มใหม่\""
		restart_button.visible = true


func _apply_tile_color(btn: Button, color: Color) -> void:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.corner_radius_top_left = CORNER_RADIUS
	style.corner_radius_top_right = CORNER_RADIUS
	style.corner_radius_bottom_left = CORNER_RADIUS
	style.corner_radius_bottom_right = CORNER_RADIUS
	btn.add_theme_stylebox_override("normal", style)
	btn.add_theme_stylebox_override("hover", style)
	btn.add_theme_stylebox_override("pressed", style)
	btn.add_theme_stylebox_override("focus", style)
	btn.add_theme_stylebox_override("disabled", style)


func _update_history_label() -> void:
	history_label.text = "\n".join(history_lines)
