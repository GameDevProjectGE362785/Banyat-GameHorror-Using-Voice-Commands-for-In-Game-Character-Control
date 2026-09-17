extends Control

const ITEMS := [
	{"id": "wrench", "emoji": "🔧", "name": "ประแจ"},
	{"id": "hammer", "emoji": "🔨", "name": "ค้อน"},
	{"id": "screwdriver", "emoji": "🪛", "name": "ไขควง"},
	{"id": "toolbox", "emoji": "🧰", "name": "กล่องเครื่องมือ"},
]

const ToolItemScript := preload("res://minigame/Toolsort/tool_item.gd")

@onready var status_label: Label = $VBox/StatusLabel
@onready var tray_container: HBoxContainer = $VBox/TrayContainer
@onready var slots_container: HBoxContainer = $VBox/SlotsContainer
@onready var restart_button: Button = $VBox/RestartButton

var slots: Array = []
var filled_count: int = 0


func _ready() -> void:
	for slot in slots_container.get_children():
		slots.append(slot)
		slot.item_dropped.connect(_on_item_dropped)

	restart_button.pressed.connect(_start_game)
	restart_button.visible = false
	_start_game()


func _start_game() -> void:
	restart_button.visible = false
	filled_count = 0
	status_label.text = "ลากอุปกรณ์แต่ละชิ้นไปวางในช่องให้ถูกต้อง (ลองผิดลองถูกได้)"

	# สุ่มว่าอุปกรณ์แต่ละชิ้นควรอยู่ช่องไหน (โจทย์สุ่มทุกครั้ง)
	var shuffled_for_slots: Array = ITEMS.duplicate()
	shuffled_for_slots.shuffle()

	for i in slots.size():
		var slot = slots[i]
		slot.filled = false
		slot.correct_item_id = shuffled_for_slots[i]["id"]
		slot.reset_color()
		for c in slot.content.get_children():
			slot.content.remove_child(c)
			c.queue_free()

	# สุ่มลำดับที่แสดงในถาดของ ไม่ให้ตรงกับลำดับช่องพอดี
	var tray_order: Array = ITEMS.duplicate()
	tray_order.shuffle()

	for c in tray_container.get_children():
		tray_container.remove_child(c)
		c.queue_free()

	for data in tray_order:
		tray_container.add_child(_make_item(data))


func _make_item(data: Dictionary) -> Control:
	var item := ToolItemScript.new()
	item.item_id = data["id"]
	item.custom_minimum_size = Vector2(76, 76)

	var vb := VBoxContainer.new()
	vb.alignment = BoxContainer.ALIGNMENT_CENTER
	vb.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var emoji_label := Label.new()
	emoji_label.text = data["emoji"]
	emoji_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	emoji_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	emoji_label.add_theme_font_size_override("font_size", 28)

	var name_label := Label.new()
	name_label.text = data["name"]
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	name_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	name_label.add_theme_font_size_override("font_size", 11)

	vb.add_child(emoji_label)
	vb.add_child(name_label)
	item.add_child(vb)
	return item


func _on_item_dropped(item: Control, slot: Control) -> void:
	if slot.filled:
		return

	if item.item_id == slot.correct_item_id:
		tray_container.remove_child(item)
		slot.content.add_child(item)
		item.lock()
		slot.mark_correct()
		filled_count += 1
		if filled_count >= slots.size():
			status_label.text = "สำเร็จ! 🎉 จัดเรียงอุปกรณ์ถูกต้องครบทุกชิ้นแล้ว"
			restart_button.visible = true
	else:
		slot.flash_wrong()
