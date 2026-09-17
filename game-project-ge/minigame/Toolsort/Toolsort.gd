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
@onready var Exitt: Button = $Exit

var slots: Array = []
var filled_count: int = 0


func _ready() -> void:
	for slot in slots_container.get_children():
		slots.append(slot)
		slot.item_dropped.connect(_on_item_dropped)

	restart_button.pressed.connect(_start_game)
	restart_button.visible = false

	Exitt.pressed.connect(stopGame)

	# ถ้าเคยผ่านมินิเกมนี้แล้ว
	if EventScheduler.TollSort:
		status_label.text = "ผ่านการทดสอบนี้แล้ว"
		_set_items_disabled(true)

		await get_tree().create_timer(3.0).timeout

		visible = false
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		return

	_start_game()


func stopGame() -> void:
	visible = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _start_game() -> void:
	# ถ้าเคยผ่านแล้ว ห้ามเล่นอีก
	if EventScheduler.TollSort:
		status_label.text = "ผ่านการทดสอบนี้แล้ว"
		restart_button.visible = false
		_set_items_disabled(true)

		await get_tree().create_timer(3.0).timeout

		visible = false
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		return

	restart_button.visible = false
	filled_count = 0

	status_label.text = "ลากอุปกรณ์แต่ละชิ้นไปวางในช่องให้ถูกต้อง (ลองผิดลองถูกได้)"

	# สุ่มว่าอุปกรณ์แต่ละชิ้นควรอยู่ช่องไหน
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

	# สุ่มลำดับอุปกรณ์ในถาด
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
	# ถ้าเคยผ่านแล้ว ไม่ให้ทำอะไร
	if EventScheduler.TollSort:
		return

	if slot.filled:
		return

	if item.item_id == slot.correct_item_id:

		tray_container.remove_child(item)
		slot.content.add_child(item)

		item.lock()
		slot.mark_correct()

		filled_count += 1

		# จัดถูกครบทุกชิ้น
		if filled_count >= slots.size():

			status_label.text = "สำเร็จ! 🎉 จัดเรียงอุปกรณ์ถูกต้องครบทุกชิ้นแล้ว"

			# บันทึกว่าผ่านมินิเกม ToolSort แล้ว
			EventScheduler.TollSort = true

			print("TollSort = ", EventScheduler.TollSort)

			restart_button.visible = false

			await get_tree().create_timer(3.0).timeout

			visible = false
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	else:
		slot.flash_wrong()


func _set_items_disabled(disabled: bool) -> void:
	# ปิดการลากอุปกรณ์ทั้งหมด
	for item in tray_container.get_children():
		if item.has_method("set_process"):
			item.set_process(not disabled)

		if item is Control:
			item.mouse_filter = Control.MOUSE_FILTER_IGNORE if disabled else Control.MOUSE_FILTER_PASS
