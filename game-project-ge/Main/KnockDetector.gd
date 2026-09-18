extends Node

# ==========================================================
# SIGNALS - KNOCK (เดิม)
# ==========================================================
signal knock_detected(count: int)
signal knock_sequence_completed
signal knock_sequence_failed
signal knock_finished(passed: bool)

# ==========================================================
# SIGNALS - SHARP SOUND (ใหม่ / เสียงแหลม)
# ==========================================================
signal sharp_detected(count: int)
signal sharp_sequence_completed
signal sharp_sequence_failed
signal sharp_finished(passed: bool)

# ==========================================================
# EXPORT - GENERAL
# ==========================================================
@export var bus_name: String = "Mic"
@export var sequence_timeout: float = 3.0

# ==========================================================
# EXPORT - KNOCK
# ==========================================================
@export var required_knocks: int = 3
@export var threshold: float = 0.25
@export var release_threshold: float = 0.10
@export var cooldown: float = 0.12

# ==========================================================
# EXPORT - SHARP SOUND
# เสียงแหลม = ความดังถึงเกณฑ์ + อัตรา zero-crossing (ความถี่) สูง
# ==========================================================
@export var required_sharps: int = 3
@export var sharp_threshold: float = 0.20       # ความดังขั้นต่ำที่นับเป็นเสียง
@export var sharp_release_threshold: float = 0.08
@export var sharp_cooldown: float = 0.12
@export var zcr_threshold: float = 0.35         # ยิ่งสูง = เสียงแหลม/ความถี่สูงยิ่งมาก (ค่า 0.0 - 1.0)

# ==========================================================
# INTERNAL STATE
# ==========================================================
enum Mode { NONE, KNOCK, SHARP }

var _capture: AudioEffectCapture
var _active: bool = false
var _mode: int = Mode.NONE

var _count: int = 0
var _cooldown_timer: float = 0.0
var _sequence_timer: float = 0.0
var _armed: bool = true

var last_result: String = "none"


var is_listening: bool:
	get:
		return _active


var knock_count: int:
	get:
		return _count if _mode == Mode.KNOCK else 0


var sharp_count: int:
	get:
		return _count if _mode == Mode.SHARP else 0


func _ready() -> void:
	var idx := AudioServer.get_bus_index(bus_name)

	if idx == -1:
		push_error("ไม่พบ Audio Bus: " + bus_name)
		return

	for i in AudioServer.get_bus_effect_count(idx):
		var fx := AudioServer.get_bus_effect(idx, i)

		if fx is AudioEffectCapture:
			_capture = fx
			break

	if _capture == null:
		push_error("ไม่พบ AudioEffectCapture บน bus: " + bus_name)
		return

	set_process(false)


# =========================================================
# START LISTENING - KNOCK (เดิม)
# คืนค่า true = เคาะผ่าน / false = เคาะไม่ผ่าน
# =========================================================

func start_listening() -> bool:
	if _capture == null or _active:
		return false

	_begin_session(Mode.KNOCK)

	print("เริ่มฟังเสียงเคาะ")

	var result: bool = await knock_finished

	return result


# =========================================================
# START LISTENING - SHARP SOUND (ใหม่)
# ใช้งานเหมือนกับ start_listening() ของการเคาะ
# คืนค่า true = ทำเสียงแหลมครบตามที่กำหนด
# คืนค่า false = ไม่ครบภายในเวลาที่กำหนด
# =========================================================

func start_listening_sharp() -> bool:
	if _capture == null or _active:
		return false

	_begin_session(Mode.SHARP)

	print("เริ่มฟังเสียงแหลม")

	var result: bool = await sharp_finished

	return result


func _begin_session(mode: int) -> void:
	_capture.clear_buffer()

	_active = true
	_mode = mode
	_count = 0
	_cooldown_timer = 0.0
	_sequence_timer = 0.0
	_armed = true
	last_result = "none"

	set_process(true)


# =========================================================
# STOP
# =========================================================

func stop_listening() -> void:
	_active = false
	_mode = Mode.NONE
	set_process(false)


# =========================================================
# PROCESS
# =========================================================

func _process(delta: float) -> void:
	if not _active or _capture == null:
		return

	_sequence_timer += delta

	# =====================================================
	# TIMEOUT = ไม่ผ่าน
	# =====================================================

	if _sequence_timer >= sequence_timeout:
		_fail_current_mode()
		return

	# =====================================================
	# COOLDOWN
	# =====================================================

	if _cooldown_timer > 0.0:
		_cooldown_timer -= delta

	# =====================================================
	# GET MICROPHONE DATA
	# =====================================================

	var frames := _capture.get_frames_available()

	if frames <= 0:
		return

	var buffer := _capture.get_buffer(frames)
	var metrics := _analyze_buffer(buffer)

	if _mode == Mode.KNOCK:
		_process_knock(metrics.peak)
	elif _mode == Mode.SHARP:
		_process_sharp(metrics.peak, metrics.zcr)


# =========================================================
# วิเคราะห์บัฟเฟอร์เสียง
# peak = ความดังสูงสุด, zcr = อัตรา zero-crossing (ตัวแทนความ "แหลม"/ความถี่)
# =========================================================

func _analyze_buffer(buffer: PackedVector2Array) -> Dictionary:
	var peak := 0.0
	var zero_crossings := 0
	var prev_sample := 0.0
	var has_prev := false

	for f in buffer:
		var sample := (f.x + f.y) * 0.5

		peak = max(peak, max(absf(f.x), absf(f.y)))

		if has_prev and ((prev_sample >= 0.0) != (sample >= 0.0)):
			zero_crossings += 1

		prev_sample = sample
		has_prev = true

	var zcr := 0.0

	if buffer.size() > 1:
		zcr = float(zero_crossings) / float(buffer.size() - 1)

	return {"peak": peak, "zcr": zcr}


# =========================================================
# KNOCK LOGIC (เดิม)
# =========================================================

func _process_knock(peak: float) -> void:
	if _armed and peak >= threshold and _cooldown_timer <= 0.0:

		_armed = false
		_cooldown_timer = cooldown
		_count += 1

		print("เคาะ %d/%d | peak %.3f" % [_count, required_knocks, peak])

		knock_detected.emit(_count)

		if _count >= required_knocks:
			last_result = "success"
			print("เคาะครบแล้ว!")
			stop_listening()
			knock_sequence_completed.emit()
			knock_finished.emit(true)
			return

	elif not _armed and peak < release_threshold:
		_armed = true


# =========================================================
# SHARP SOUND LOGIC (ใหม่)
# นับเป็น 1 ครั้ง เมื่อความดังถึงเกณฑ์ "และ" zero-crossing rate สูงพอ (แหลม)
# =========================================================

func _process_sharp(peak: float, zcr: float) -> void:
	if _armed and peak >= sharp_threshold and zcr >= zcr_threshold and _cooldown_timer <= 0.0:

		_armed = false
		_cooldown_timer = sharp_cooldown
		_count += 1

		print("เสียงแหลม %d/%d | peak %.3f | zcr %.3f" % [_count, required_sharps, peak, zcr])

		sharp_detected.emit(_count)

		if _count >= required_sharps:
			last_result = "success"
			print("ทำเสียงแหลมครบแล้ว!")
			stop_listening()
			sharp_sequence_completed.emit()
			sharp_finished.emit(true)
			return

	elif not _armed and peak < sharp_release_threshold:
		_armed = true


# =========================================================
# TIMEOUT HANDLER แยกตามโหมด
# =========================================================

func _fail_current_mode() -> void:
	last_result = "failed"

	if _mode == Mode.KNOCK:
		print("เคาะไม่ครบ ได้ %d/%d" % [_count, required_knocks])
		stop_listening()
		knock_sequence_failed.emit()
		knock_finished.emit(false)
	elif _mode == Mode.SHARP:
		print("ทำเสียงแหลมไม่ครบ ได้ %d/%d" % [_count, required_sharps])
		stop_listening()
		sharp_sequence_failed.emit()
		sharp_finished.emit(false)
	else:
		stop_listening()
