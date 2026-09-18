extends Node
var ShutDown = true
signal beat_triggered(hour: int, beat_id: StringName)
var crying_event_active = false
var crying_event_start_minutes = -1
var crying_event_index = -1
@onready var crying_sound: AudioStreamPlayer = $CrySound
var current_hour := 0
var current_minute := 0
var BoxQuestCount = 0
var Box2QuestCount = 0
var SaveZone = false
var CharacinGodang1 = false
var CharacinGodang2 = false
var CharacinGodang3 = false
var GhoustinGodang1 = false
var GhoustinGodang2 = false
var GhoustinGodang3 = false
var playerAlive = true
var door_locked1 = false
var door_locked2 = false
var door_locked3 = false
var SafeRoomLock = false

var RunNumber = false #ตรวจใบส่งของรอบกลางคืน (มินิเกม)
var TollSort = false  #จัดเรียงอุปกรณ์บนชั้น B (มินิเกม)
var DifColor = false #เช็กของชำรุด 3 กล่อง (มินิเกม)
var BoxCheck = false #ตรวจเลขสินค้า A-01 ถึง A-05 (หากลอง 1 - 5 ให้ครบ)
var Fix = false #ช่อมเครื่องปั่นไฟ 
var GodangTwoCheck = false #เช็คของในโกดัง 2 (หาของให้ครบ)
var fuseCheck = false #เปลี่ยน Fuse ตู้ไฟ (หาฟิวตามแมพ)
var CutOut = false #ปิดเครื่องจักร ปิดคัตเอ้า (มินิเกม)



const BEATS: Dictionary = {
	0: &"intro_blackout",
	1: &"machine_check",
	2: &"delivery_arrival",
	3: &"clean_blood",
	4: &"fridge_ritual",
	5: &"dread_escalation",
	6: &"door_knock_finale",
}

var last_triggered_hour := -1
var triggered_beats: Array[StringName] = []

func update_ghouston_status():
	var total_minutes = current_hour * 60 + current_minute
	
	if CharacinGodang1:
		GhoustinGodang1 = false

	elif total_minutes >= 0 and total_minutes < 30:
		GhoustinGodang1 = false

	elif total_minutes >= 60 and total_minutes < 120:
		GhoustinGodang1 = false

	elif total_minutes >= 150 and total_minutes < 180:
		GhoustinGodang1 = false

	elif total_minutes >= 210 and total_minutes < 240:
		GhoustinGodang1 = false

	elif total_minutes >= 300 and total_minutes < 330:
		GhoustinGodang1 = false

	else:
		GhoustinGodang1 = true


	# =====================================================
	# โกดัง 2
	#
	# เข้าได้:
	# 00:00–01:00
	# 01:30–02:30
	# 03:30–04:00
	# =====================================================

	if CharacinGodang2:
		GhoustinGodang2 = false

	elif total_minutes >= 0 and total_minutes < 60:
		GhoustinGodang2 = false

	elif total_minutes >= 90 and total_minutes < 150:
		GhoustinGodang2 = false

	elif total_minutes >= 210 and total_minutes < 240:
		GhoustinGodang2 = false

	else:
		GhoustinGodang2 = true


	# =====================================================
	# โกดัง 3
	#
	# เข้าได้:
	# 00:00–01:30
	# 02:00–03:00
	# 04:00–04:30
	# 05:00–05:30
	# =====================================================

	if CharacinGodang3:
		GhoustinGodang3 = false

	elif total_minutes >= 0 and total_minutes < 90:
		GhoustinGodang3 = false

	elif total_minutes >= 120 and total_minutes < 180:
		GhoustinGodang3 = false

	elif total_minutes >= 240 and total_minutes < 270:
		GhoustinGodang3 = false

	elif total_minutes >= 300 and total_minutes < 330:
		GhoustinGodang3 = false

	else:
		GhoustinGodang3 = true

func update_safe_room_lock() -> void:
	var total_minutes := current_hour * 60 + current_minute

	if total_minutes == 130: # 02:10
		SafeRoomLock = true
		print("SafeRoomLock = TRUE at 02:10")

	elif total_minutes == 210: # 03:30
		SafeRoomLock = true
		print("SafeRoomLock = TRUE at 03:30")

	elif total_minutes == 300: # 05:00
		SafeRoomLock = true
		print("SafeRoomLock = TRUE at 05:00")
		
func check_crying_event():
	var total_minutes = current_hour * 60 + current_minute

	# =========================
	# เริ่ม Event
	# =========================

	if not crying_event_active:

		if total_minutes == 105: # 01:45
			start_crying_event(105, 0)

		elif total_minutes == 225: # 03:45
			start_crying_event(225, 1)

		elif total_minutes == 315: # 05:15
			start_crying_event(315, 2)


	# =========================
	# กำลังอยู่ใน Event
	# =========================

	else:

		# ถ้าเข้า SaveZone แล้ว
		if SaveZone:
			stop_crying_event()
			return

		# ครบ 30 นาที
		if total_minutes >= crying_event_start_minutes + 30:
			playerAlive = false
			stop_crying_event()


func start_crying_event(start_time: int, event_index: int):
	
	crying_event_active = true
	crying_event_start_minutes = start_time
	crying_event_index = event_index
	print("crying_sound = ", crying_sound)
	print("is_instance_valid = ", is_instance_valid(crying_sound))
	print("has_node = ", has_node("CrySound"))
	# เปิดเสียงร้องไห้
	crying_sound.play()


func stop_crying_event():

	crying_event_active = false
	crying_event_start_minutes = -1

	# ปิดเสียง
	if crying_sound.playing:
		crying_sound.stop()
func _ready() -> void:
	print("SELF: ", self)
	print("CRY: ", $CrySound)
	# KnockDetector เป็น Autoload (Global) แล้ว เข้าถึงตรงๆ ผ่านชื่อ ไม่ต้อง get_node
	Knockdetector.knock_detected.connect(_on_knock)
	Knockdetector.knock_sequence_completed.connect(_on_success)
	Knockdetector.knock_sequence_failed.connect(_on_fail)

	GameClock.hour_tick.connect(_on_hour_tick)

	# เชื่อม beat_triggered เข้ากับ event จริง (จุดที่ขาดไปก่อนหน้านี้)
	beat_triggered.connect(_on_beat_triggered)

	_on_hour_tick(EventScheduler.current_hour)


			
			
func _on_beat_triggered(hour: int, beat_id: StringName) -> void:
	match beat_id:
		&"intro_blackout":
			pass # TODO: ใส่ logic ของ beat นี้
		&"machine_check":
			pass
		&"delivery_arrival":
			pass
		&"clean_blood":
			pass
		&"fridge_ritual":
			pass
		&"dread_escalation":
			pass
		&"door_knock_finale":
			on_my_event_started()


func on_my_event_started() -> void:
	print("เคาะโต๊ะ 3 ครั้ง!")
	Knockdetector.start_listening()


func _on_knock(count: int) -> void:
	print("เคาะแล้ว")


func _on_success() -> void:
	print("สำเร็จ...")


func _on_fail() -> void:
	print("ล้มเหลว")


func get_beat_id(hour: int) -> StringName:
	return BEATS.get(hour, &"")


func has_beat(hour: int) -> bool:
	return BEATS.has(hour)


func trigger_beat(hour: int) -> void:
	_on_hour_tick(hour)


func reset() -> void:
	last_triggered_hour = -1
	triggered_beats.clear()
	_on_hour_tick(GameClock.EventScheduler.current_hour)


func _on_hour_tick(hour: int) -> void:
	if hour == last_triggered_hour:
		return

	last_triggered_hour = hour
	var beat_id := get_beat_id(hour)
	if beat_id.is_empty():
		return

	triggered_beats.append(beat_id)
	beat_triggered.emit(hour, beat_id)
	print("EventScheduler: %02d:00 -> %s" % [hour, beat_id])
