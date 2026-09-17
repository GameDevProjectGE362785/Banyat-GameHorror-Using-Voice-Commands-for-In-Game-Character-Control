extends Node

signal hour_tick(hour: int)
signal time_changed(hour: int, minute: int)
signal night_finished

const START_TIME_SECONDS := 0.0
const END_TIME_SECONDS := 6.0 * 60.0 * 60.0

## Real seconds required to advance one in-game hour.
@export_range(0.1, 3600.0, 0.1) var time_compression := 60.0

var elapsed_game_seconds := START_TIME_SECONDS
var is_running := true


func _ready() -> void:
	_reset_display()
	hour_tick.emit(EventScheduler.current_hour)


func _process(delta: float) -> void:
	if not is_running:
		return

	var previous_hour = EventScheduler.current_hour
	elapsed_game_seconds = min(
		elapsed_game_seconds + delta * 3600.0 / time_compression,
		END_TIME_SECONDS
	)
	_update_display()

	if EventScheduler.current_hour != previous_hour:
		hour_tick.emit(EventScheduler.current_hour)

	if elapsed_game_seconds >= END_TIME_SECONDS:
		is_running = false
		night_finished.emit()


func start() -> void:
	if elapsed_game_seconds < END_TIME_SECONDS:
		is_running = true


func pause() -> void:
	is_running = false


func reset() -> void:
	elapsed_game_seconds = START_TIME_SECONDS
	is_running = true
	_reset_display()
	hour_tick.emit(EventScheduler.current_hour)


func get_time_text() -> String:
	return "%02d:%02d" % [EventScheduler.current_hour, EventScheduler.current_minute]


func _reset_display() -> void:
	EventScheduler.current_hour = 0
	EventScheduler.current_minute = 0
	time_changed.emit(EventScheduler.current_hour, EventScheduler.current_minute)


func _update_display() -> void:
	var total_minutes := int(elapsed_game_seconds / 60.0)
	EventScheduler.current_hour = total_minutes / 60
	EventScheduler.current_minute = total_minutes % 60
	time_changed.emit(EventScheduler.current_hour, EventScheduler.current_minute)
