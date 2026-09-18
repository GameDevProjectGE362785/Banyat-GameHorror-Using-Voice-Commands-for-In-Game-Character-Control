extends CharacterBody3D

@onready var raycast = $CameraController/RayCast3D
@onready var UI = $CameraView
@onready var flashlight = $CameraController/SpotLight3D
@onready var camera = $CameraController/Camera3D

const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const MOUSE_SENSITIVITY = 0.003

@onready var wrenchHand = $CameraController/Camera3D/HandedItem/Wrench
@onready var boxHand = $CameraController/Camera3D/HandedItem/Box
@onready var fuseHand = $CameraController/Camera3D/HandedItem/Fuse
@onready var KeyHand = $CameraController/Camera3D/HandedItem/Key

var ItemOnHand = "none"
var current_godang := 0
var door_lock_timer := 0.0
var door_timer_started := false
var flashlighton = false

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

#Control rotate
func _input(event: InputEvent) -> void:
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED :
		if event is InputEventMouseMotion:
			# Rotate the whole player body left/right (yaw)
			rotate_y(-event.relative.x * MOUSE_SENSITIVITY)

	if event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


#Control Movement
func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	#if Input.is_action_just_pressed("ui_accept") and is_on_floor():
	#	velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED :
		if EventScheduler.playerAlive:
			var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
			var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
			if direction:
				velocity.x = direction.x * SPEED
				velocity.z = direction.z * SPEED
			else:
				velocity.x = move_toward(velocity.x, 0, SPEED)
				velocity.z = move_toward(velocity.z, 0, SPEED)

			move_and_slide()

#Control interactive
func _process(delta: float) -> void:
	print(ResourceLoader.exists("res://Main/MainMenuUI.tscn"))
	if !EventScheduler.playerAlive:
		print("1: Player Dead")

		$AnimationPlayer.play("Dead")
		await get_tree().create_timer(6).timeout
		print("2: 6 seconds passed")

		$AnimationPlayer.stop()
		$Control.visible = true
		print("3: Control visible")

		await get_tree().create_timer(2).timeout
		print("4: Changing to MainMenu")

		var error = get_tree().change_scene_to_file("res://Main/MainMenuUI.tscn")
		print("5: Change scene result = ", error)
	EventScheduler.update_ghouston_status()
	EventScheduler.update_safe_room_lock()
	if EventScheduler.GhoustinGodang1 == true and EventScheduler.CharacinGodang1 == true:
		EventScheduler.playerAlive = false
	if EventScheduler.GhoustinGodang2 == true and EventScheduler.CharacinGodang2 == true:
		EventScheduler.playerAlive = false
	if EventScheduler.GhoustinGodang3 == true and EventScheduler.CharacinGodang3 == true:
		EventScheduler.playerAlive = false
	EventScheduler.check_crying_event()
	checkObjectInfront()
	if Input.is_action_just_pressed("flashlight"):
		flashLightFunction()
	if Input.is_action_just_pressed("CheckLowhigh"):
		EventScheduler.RunNumber = true
		EventScheduler.ShutDown = true
		EventScheduler.TollSort = true
		EventScheduler.DifColor = true
		EventScheduler.BoxCheck = true
		EventScheduler.Fix = true
		EventScheduler.GodangTwoCheck = true
	if Input.is_key_pressed(KEY_B):
		EventScheduler.SafeRoomLock = !EventScheduler.SafeRoomLock
		print("TEST: SafeRoomLock = true")

	# กด N = ล็อกประตูโกดังปัจจุบัน
	if Input.is_key_pressed(KEY_N):
		if current_godang > 0:
			EventScheduler.set(
				"door_locked" + str(current_godang),
				true
			)

			print("TEST: doorlock", current_godang, " = true")
		else:
			print("TEST: ไม่ได้อยู่ในโกดัง")
var textChange = false

func check_random_door_lock(delta: float) -> void:
	# =========================
	# เข้าโกดัง 1
	# =========================
	if EventScheduler.CharacinGodang1 and current_godang != 1:
		current_godang = 1
		door_timer_started = true
		door_lock_timer = randf_range(10.0, 30.0)

		EventScheduler.doorlock1 = false

		print("เข้าโกดัง 1")
		print("ประตูจะล็อกใน ", door_lock_timer, " วินาที")


	# =========================
	# เข้าโกดัง 2
	# =========================
	elif EventScheduler.CharacinGodang2 and current_godang != 2:
		current_godang = 2
		door_timer_started = true
		door_lock_timer = randf_range(10.0, 30.0)

		EventScheduler.doorlock2 = false

		print("เข้าโกดัง 2")
		print("ประตูจะล็อกใน ", door_lock_timer, " วินาที")


	# =========================
	# เข้าโกดัง 3
	# =========================
	elif EventScheduler.CharacinGodang3 and current_godang != 3:
		current_godang = 3
		door_timer_started = true
		door_lock_timer = randf_range(10.0, 30.0)

		EventScheduler.doorlock3 = false

		print("เข้าโกดัง 3")
		print("ประตูจะล็อกใน ", door_lock_timer, " วินาที")


	# =========================
	# นับเวลา
	# =========================
	if door_timer_started:
		door_lock_timer -= delta

		if door_lock_timer <= 0.0:
			door_timer_started = false

			if current_godang == 1:
				EventScheduler.doorlock1 = true
				print("ประตูโกดัง 1 ล็อกแล้ว")

			elif current_godang == 2:
				EventScheduler.doorlock2 = true
				print("ประตูโกดัง 2 ล็อกแล้ว")

			elif current_godang == 3:
				EventScheduler.doorlock3 = true
				print("ประตูโกดัง 3 ล็อกแล้ว")


	# =========================
	# ออกจากโกดังทั้งหมด
	# =========================
	if not EventScheduler.CharacinGodang1 \
	and not EventScheduler.CharacinGodang2 \
	and not EventScheduler.CharacinGodang3:

		current_godang = 0
		door_timer_started = false
func checkObjectInfront():
	if not raycast.is_colliding():
		UI.setCollition(false)
		return
	
	var item = raycast.get_collider()
	var picked := Input.is_action_just_pressed("PickUp")

	if item.is_in_group("door"):
		if item.is_in_group("saveRoom") and EventScheduler.SafeRoomLock:
			if ItemOnHand == "Key":
				hideItemInHand()
				EventScheduler.SafeRoomLock = false
				item.interactive()
			else:
				UI.TextChanger("ต้องใช้ Key เพื่อเปิดประตู")
				textChange = true
				await get_tree().create_timer(0.8).timeout
				textChange = false
			return
			
		if Input.is_action_just_pressed("checkmic"):
			var door_number: int = item.NumberDoor
			var is_locked: bool = EventScheduler.get("doorlock" + str(door_number))
			if is_locked:
				var unlocked: bool = await Knockdetector.start_listening_sharp()
				if unlocked:
					EventScheduler.set("doorlock" + str(door_number), false)
			var passed: bool = await Knockdetector.start_listening()
			if passed:
				print("เคาะผ่าน")
				# ทำสิ่งที่ต้องการเมื่อเคาะผ่าน
				print(EventScheduler.get("CharacinGodang" + str(item.NumberDoor)))
				print(("GhoustinGodang" + str(item.NumberDoor)))
				print(EventScheduler.get("GhoustinGodang" + str(item.NumberDoor)))
				if EventScheduler.get("GhoustinGodang" + str(item.NumberDoor)) == true:
					item.get_node("Knock").play()
			else:
				print("เคาะไม่ผ่าน")
				# ทำสิ่งที่ต้องการเมื่อเคาะไม่ผ่าน
	
	# =========================================================
	# BOX
	# =========================================================
	if item.is_in_group("Box") and picked:
		item.remove_from_group("Box")
		item.disable_collision()
		EventScheduler.BoxQuestCount += 1
		if EventScheduler.BoxQuestCount >= 5:
			EventScheduler.BoxCheck = true
		return
	if item.is_in_group("Box2") and picked:
		item.remove_from_group("Box2")
		item.disable_collision()
		EventScheduler.Box2QuestCount += 1
		if EventScheduler.Box2QuestCount >= 5:
			EventScheduler.GodangTwoCheck = true
		return
	# =========================================================
	# DINAMO
	# =========================================================
	if item.is_in_group("dinamo") and ItemOnHand == "Wrench" and picked:
		print("เจอแบ้วจ้า")
		print(ItemOnHand)

		item.get_node("CheckEvent").visible = true
		item.get_node("CheckEvent").open_event()
		return
	# =========================================================
	# EVENT ITEM
	# =========================================================
	if item.is_in_group("EventItem"):
		if not textChange:
			UI.setCollition(true)
			UI.TextChanger(item.getInteractive())
		if picked:
			item.interactive()
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		return
	# =========================================================
	# ELECTRIC BOX
	# =========================================================
	if item.is_in_group("ElecBox"):
		if not textChange:
			UI.setCollition(true)
			UI.TextChanger(item.getInteractive())
		if not picked:
			return
		var used: bool = item.use_item(ItemOnHand)
		if used and ItemOnHand == "Fuse":
			hideItemInHand()
			ItemOnHand = "none"
			return
		if not used and ItemOnHand != "Fuse" and not item.powered:
			UI.TextChanger("ต้องถือ Fuse อยู่ในมือก่อน")
			textChange = true
			await get_tree().create_timer(0.8).timeout
			textChange = false
		return
	# =========================================================
	# ITEM CLASS
	# =========================================================
	if item is ClassItem:
		print(ItemOnHand)
		if not textChange:
			UI.setCollition(true)
			UI.TextChanger(item.getInteractive())
		if picked:
			if ItemOnHand != "none":

				checkItemOnHand(item)
			else:
				showItemandUseItemInHand(item)
		return

func checkItemOnHand(item):
	if item.is_in_group("door"):
		item.interactive()
		return
		
	elif item is Wrench and ItemOnHand == "Wrench" :
		if !item.getOnTable():
			hideItemInHand()
			item.interactive()
			ItemOnHand = "none"
	elif item is Key and ItemOnHand == "Key" :
		if !item.getOnTable():
			hideItemInHand()
			item.interactive()
			ItemOnHand = "none"
	else:
		UI.TextChanger("Hand are Full")
		textChange = true
		await get_tree().create_timer(0.8).timeout
		textChange = false
	
func showItemandUseItemInHand(item: ClassItem) -> void:
	var inputItem = item.get_item_name()
	if item.is_in_group('door'):
		item.interactive()
		return
	if inputItem == "Box":
		return
	if inputItem == "Key":
		KeyHand.visible = true
	if inputItem == "Wrench":
		wrenchHand.visible = true
	elif inputItem == "Fuse":
		fuseHand.visible = true
	ItemOnHand = inputItem
	item.interactive()

func hideItemInHand() -> void:
	if ItemOnHand == "Wrench":
		wrenchHand.visible = false
	elif ItemOnHand == "Fuse":
		fuseHand.visible = false
	elif ItemOnHand == "Key":
		KeyHand.visible = false

func get_visual_bottom(node: Node3D) -> float:
	var lowest_y: float = INF
	for child in node.get_children():
		if child is VisualInstance3D:
			var visual: VisualInstance3D = child as VisualInstance3D
			var bounds: AABB = visual.get_aabb()
			for x in [bounds.position.x, bounds.end.x]:
				for y in [bounds.position.y, bounds.end.y]:
					for z in [bounds.position.z, bounds.end.z]:
						var world_point: Vector3 = visual.global_transform * Vector3(x, y, z)
						lowest_y = minf(lowest_y, world_point.y)
		if child is Node3D:
			lowest_y = minf(lowest_y, get_visual_bottom(child as Node3D))
	return lowest_y

func flashLightFunction():
	flashlighton = !flashlighton
	flashlight.visible = flashlighton


	
