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
	MAP.visible = false


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


func _process(_delta: float) -> void:
	# อัปเดตเวลา/Deadline ขณะเปิด UI
	if panel.visible or MAP.visible:
		update_quest()


# =========================================================
# UPDATE QUEST
# =========================================================

func update_quest() -> void:

	run_number.text = get_quest_text(
		"ตรวจใบส่งของรอบกลางคืน",
		EventScheduler.RunNumber,
		3,
		30
	)

	toll_sort.text = get_quest_text(
		"จัดเรียงอุปกรณ์บนชั้น B",
		EventScheduler.TollSort,
		4,
		45
	)

	dif_color.text = get_quest_text(
		"เช็กของชำรุด 3 กล่อง ที่โกดัง1",
		EventScheduler.DifColor,
		4,
		30
	)

	box_check.text = get_quest_text(
		"ตรวจเลขสินค้าที่shelf",
		EventScheduler.BoxCheck,
		2,
		30
	)

	fix.text = get_quest_text(
		"ซ่อมเครื่องปั่นไฟ",
		EventScheduler.Fix,
		3,
		0
	)

	godang_two_check.text = get_quest_text(
		"เช็คของในโกดัง 2",
		EventScheduler.GodangTwoCheck,
		5,
		0
	)

	fuse_check.text = get_quest_text(
		"เปลี่ยน Fuse ตู้ไฟ",
		EventScheduler.fuseCheck,
		1,
		0
	)

	cut_out.text = get_quest_text(
		"ปิดเครื่องจักร / ปิดคัตเอ้า",
		EventScheduler.CutOut,
		5,
		30
	)


# =========================================================
# QUEST TEXT
# =========================================================

func get_quest_text(
	quest_name: String,
	completed: bool,
	deadline_hour: int,
	deadline_minute: int
) -> String:

	var deadline_text := "%02d:%02d" % [
		deadline_hour,
		deadline_minute
	]

	# =====================================================
	# ทำงานเสร็จแล้ว
	# =====================================================
	if completed:
		return "✓  %s  [%s]" % [
			quest_name,
			deadline_text
		]

	# =====================================================
	# เวลาปัจจุบัน
	# =====================================================
	var current_minutes: int = (
		EventScheduler.current_hour * 60
		+ EventScheduler.current_minute
	)
	var deadline_minutes := (
		deadline_hour * 60
		+ deadline_minute
	)

	# =====================================================
	# หมดเวลา
	# =====================================================
	if current_minutes >= deadline_minutes:
		return "✕  %s  [หมดเวลา %s]" % [
			quest_name,
			deadline_text
		]

	# =====================================================
	# ยังไม่ถึง Deadline
	# =====================================================
	return "○  %s  [%s]" % [
		quest_name,
		deadline_text
	]
