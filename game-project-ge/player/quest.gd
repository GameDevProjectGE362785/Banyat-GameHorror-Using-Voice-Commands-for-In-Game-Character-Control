extends Control


@onready var panel: Panel = $Panel
@onready var MAP: Panel = $Panel2
@onready var title: Label = $Panel/VBoxContainer/Title
@onready var run_number: Label = $Panel/VBoxContainer/RunNumber
@onready var toll_sort: Label = $Panel/VBoxContainer/TollSort
@onready var dif_color: Label = $Panel/VBoxContainer/DifColor
@onready var box_check: Label = $Panel/VBoxContainer/BoxCheck
@onready var fix: Label = $Panel/VBoxContainer/Fix
@onready var godang_two_check: Label = $Panel/VBoxContainer/GodangTwoCheck
@onready var fuse_check: Label = $Panel/VBoxContainer/fuseCheck
@onready var cut_out: Label = $Panel/VBoxContainer/CutOut
@onready var close_button: Button = $Panel/VBoxContainer/CloseButton


func _ready() -> void:
	panel.visible = false


func _input(event: InputEvent) -> void:

	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_TAB:

			panel.visible = not panel.visible

			if panel.visible:
				update_quest()
		if event.pressed and event.keycode == KEY_M:
			print("MAP")
			MAP.visible = not MAP.visible

			if MAP.visible:
				update_quest()

func update_quest() -> void:

	run_number.text = get_quest_text(
		"ตรวจใบส่งของรอบกลางคืน",
		EventScheduler.RunNumber
	)

	toll_sort.text = get_quest_text(
		"จัดเรียงอุปกรณ์บนชั้น B",
		EventScheduler.TollSort
	)

	dif_color.text = get_quest_text(
		"เช็กของชำรุด 3 กล่อง",
		EventScheduler.DifColor
	)

	box_check.text = get_quest_text(
		"ตรวจเลขสินค้า A-01 ถึง A-05",
		EventScheduler.BoxCheck
	)

	fix.text = get_quest_text(
		"ซ่อมเครื่องปั่นไฟ",
		EventScheduler.Fix
	)

	godang_two_check.text = get_quest_text(
		"เช็คของในโกดัง 2",
		EventScheduler.GodangTwoCheck
	)

	fuse_check.text = get_quest_text(
		"เปลี่ยน Fuse ตู้ไฟ",
		EventScheduler.fuseCheck
	)

	cut_out.text = get_quest_text(
		"ปิดเครื่องจักร / ปิดคัตเอ้า",
		EventScheduler.CutOut
	)


func get_quest_text(quest_name: String, completed: bool) -> String:

	if completed:
		return "✓  " + quest_name
	else:
		return "○  " + quest_name
