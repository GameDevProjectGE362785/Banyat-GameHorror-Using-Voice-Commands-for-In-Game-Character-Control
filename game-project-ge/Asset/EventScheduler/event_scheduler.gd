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


# =========================================================
# QUEST
# =========================================================

var RunNumber = false
var TollSort = false
var DifColor = false
var BoxCheck = false
var Fix = false
var GodangTwoCheck = false
var fuseCheck = false
var CutOut = false

var Win = false


# =========================================================
# DEADLINE
# =========================================================

# เก็บ Deadline เป็น "นาทีของเกม"
#
# 01:00 = 60
# 02:30 = 150
# 03:00 = 180
# 03:30 = 210
# 04:30 = 270
# 04:45 = 285
# 05:00 = 300
# 05:30 = 330
#
const QUEST_DEADLINES: Dictionary = {
	"fuseCheck": 60,        # 01:00
	"BoxCheck": 150,        # 02:30
	"Fix": 180,              # 03:00
	"RunNumber": 210,        # 03:30
	"DifColor": 270,         # 04:30
	"TollSort": 285,         # 04:45
	"GodangTwoCheck": 300,   # 05:00
	"CutOut": 330             # 05:30
}

# ป้องกัน Deadline เดิมทำงานซ้ำ
var deadline_failed: Dictionary = {}


# =========================================================
# BEATS
# =========================================================

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

var SafeRoomLockTime := -1


# =========================================================
# PROCESS
# =========================================================

func _process(_delta: float) -> void:
	check_quest_deadlines()


# =========================================================
# CHECK QUEST DEADLINES
# =========================================================

func check_quest_deadlines() -> void:
	# ถ้าตายไปแล้ว ไม่ต้องตรวจต่อ
	if not playerAlive:
		return

	var total_minutes: int = (
		current_hour * 60
		+ current_minute
	)

	# -----------------------------------------------------
	# Fuse
	# Deadline 01:00
	# -----------------------------------------------------
	check_deadline(
		"fuseCheck",
		fuseCheck,
		60
	)

	# -----------------------------------------------------
	# BoxCheck
	# Deadline 02:30
	# -----------------------------------------------------
	check_deadline(
		"BoxCheck",
		BoxCheck,
		150
	)

	# -----------------------------------------------------
	# Fix
	# Deadline 03:00
	# -----------------------------------------------------
	check_deadline(
		"Fix",
		Fix,
		180
	)

	# -----------------------------------------------------
	# RunNumber
	# Deadline 03:30
	# -----------------------------------------------------
	check_deadline(
		"RunNumber",
		RunNumber,
		210
	)

	# -----------------------------------------------------
	# DifColor
	# Deadline 04:30
	# -----------------------------------------------------
	check_deadline(
		"DifColor",
		DifColor,
		270
	)

	# -----------------------------------------------------
	# TollSort
	# Deadline 04:45
	# -----------------------------------------------------
	check_deadline(
		"TollSort",
		TollSort,
		285
	)

	# -----------------------------------------------------
	# GodangTwoCheck
	# Deadline 05:00
	# -----------------------------------------------------
	check_deadline(
		"GodangTwoCheck",
		GodangTwoCheck,
		300
	)

	# -----------------------------------------------------
	# CutOut
	# Deadline 05:30
	# -----------------------------------------------------
	check_deadline(
		"CutOut",
		CutOut,
		330
	)


# =========================================================
# CHECK INDIVIDUAL DEADLINE
# =========================================================

func check_deadline(
	quest_name: String,
	completed: bool,
	deadline_minutes: int
) -> void:

	# ทำเสร็จแล้ว ไม่ต้องตรวจ
	if completed:
		return

	# Deadline นี้เคยทำให้ตายไปแล้ว
	if deadline_failed.get(quest_name, false):
		return

	var total_minutes: int = (
		current_hour * 60
		+ current_minute
	)

	# ยังไม่ถึง Deadline
	if total_minutes < deadline_minutes:
		return

	# =====================================================
	# หมดเวลา
	# =====================================================

	deadline_failed[quest_name] = true

	playerAlive = false

	print("========================================")
	print("QUEST DEADLINE FAILED")
	print("งาน: ", quest_name)
	print(
		"เวลาปัจจุบัน: %02d:%02d"
		% [current_hour, current_minute]
	)
	print(
		"Deadline: %02d:%02d"
		% [
			int(deadline_minutes / 60),
			deadline_minutes % 60
		]
	)
	print("งานยังไม่เสร็จ -> PLAYER DEAD")
	print("========================================")


# =========================================================
# RANDOM LOCK
# =========================================================

func RandomLock() -> void:
	var lock_after_minutes := randi_range(1, 3)

	SafeRoomLockTime = (
		current_hour * 60
		+ current_minute
		+ lock_after_minutes
	)

	print("จะล็อกประตูใน ", lock_after_minutes, " นาที")
	print("LockTime = ", SafeRoomLockTime)


func update_door_lock() -> void:
	if SafeRoomLockTime < 0:
		return

	var total_minutes: int = (
		current_hour * 60
		+ current_minute
	)

	if total_minutes >= SafeRoomLockTime:

		if CharacinGodang1:
			door_locked1 = true

		if CharacinGodang2:
			door_locked2 = true

		if CharacinGodang3:
			door_locked3 = true

		print("โกดังถูกล็อกแล้ว")

		# ป้องกันไม่ให้ทำซ้ำ
		SafeRoomLockTime = -1


# =========================================================
# GHOUST STATUS
# =========================================================

func update_ghouston_status():
	var total_minutes: int = (
		current_hour * 60
		+ current_minute
	)

	# =====================================================
	# โกดัง 1
	# =====================================================

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


# =========================================================
# OVERTIME
# =========================================================

func OverTime() -> void:
	if current_hour >= 6:
		playerAlive = false


# =========================================================
# WINNER
# =========================================================

func Winner() -> void:
	if RunNumber \
	and TollSort \
	and DifColor \
	and BoxCheck \
	and Fix \
	and GodangTwoCheck \
	and fuseCheck \
	and CutOut:

		Win = true


# =========================================================
# SAFE ROOM LOCK
# =========================================================

func update_safe_room_lock() -> void:
	var total_minutes: int = (
		current_hour * 60
		+ current_minute
	)

	if total_minutes == 130:
		SafeRoomLock = true
		print("SafeRoomLock = TRUE at 02:10")

	elif total_minutes == 210:
		SafeRoomLock = true
		print("SafeRoomLock = TRUE at 03:30")

	elif total_minutes == 300:
		SafeRoomLock = true
		print("SafeRoomLock = TRUE at 05:00")


# =========================================================
# CRYING EVENT
# =========================================================

func check_crying_event():
	var total_minutes: int = (
		current_hour * 60
		+ current_minute
	)

	# =====================================================
	# เริ่ม Event
	# =====================================================

	if not crying_event_active:

		if total_minutes == 105:
			start_crying_event(105, 0)

		elif total_minutes == 225:
			start_crying_event(225, 1)

		elif total_minutes == 315:
			start_crying_event(315, 2)

	# =====================================================
	# กำลังอยู่ใน Event
	# =====================================================

	else:

		# ถ้าเข้า SaveZone แล้ว
		if SaveZone:
			stop_crying_event()
			return

		# ครบ 10 นาที
		if total_minutes >= crying_event_start_minutes + 10:
			playerAlive = false
			stop_crying_event()


func start_crying_event(
	start_time: int,
	event_index: int
):
	crying_event_active = true
	crying_event_start_minutes = start_time
	crying_event_index = event_index

	print("crying_sound = ", crying_sound)
	print(
		"is_instance_valid = ",
		is_instance_valid(crying_sound)
	)
	print(
		"has_node = ",
		has_node("CrySound")
	)

	crying_sound.play()


func stop_crying_event():

	crying_event_active = false
	crying_event_start_minutes = -1

	if crying_sound.playing:
		crying_sound.stop()


# =========================================================
# READY
# =========================================================

func _ready() -> void:

	print("SELF: ", self)
	print("CRY: ", $CrySound)

	Knockdetector.knock_detected.connect(_on_knock)
	Knockdetector.knock_sequence_completed.connect(_on_success)
	Knockdetector.knock_sequence_failed.connect(_on_fail)

	GameClock.hour_tick.connect(_on_hour_tick)

	beat_triggered.connect(_on_beat_triggered)

	_on_hour_tick(EventScheduler.current_hour)


# =========================================================
# BEAT
# =========================================================

func _on_beat_triggered(
	hour: int,
	beat_id: StringName
) -> void:

	match beat_id:

		&"intro_blackout":
			pass

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


# =========================================================
# BEAT FUNCTIONS
# =========================================================

func get_beat_id(hour: int) -> StringName:
	return BEATS.get(hour, &"")


func has_beat(hour: int) -> bool:
	return BEATS.has(hour)


func trigger_beat(hour: int) -> void:
	_on_hour_tick(hour)


func reset() -> void:
	last_triggered_hour = -1
	triggered_beats.clear()
	deadline_failed.clear()

	_on_hour_tick(GameClock.EventScheduler.current_hour)


# =========================================================
# HOUR TICK
# =========================================================

func _on_hour_tick(hour: int) -> void:

	if hour == last_triggered_hour:
		return

	last_triggered_hour = hour

	var beat_id := get_beat_id(hour)

	if beat_id.is_empty():
		return

	triggered_beats.append(beat_id)

	beat_triggered.emit(
		hour,
		beat_id
	)

	print(
		"EventScheduler: %02d:00 -> %s"
		% [hour, beat_id]
	)
