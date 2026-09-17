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
@onready var keyhand = 1

var ItemOnHand = "none"

var flashlighton = false

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

#Control rotate
func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		# Rotate the whole player body left/right (yaw)
		rotate_y(-event.relative.x * MOUSE_SENSITIVITY)

	if event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if event is InputEventMouseButton and event.pressed:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

#Control Movement
func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	#if Input.is_action_just_pressed("ui_accept") and is_on_floor():
	#	velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
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
	checkObjectInfront()
	if Input.is_action_just_pressed("flashlight"):
		flashLightFunction()

var textChange = false
func checkObjectInfront():
	if raycast.is_colliding():
		var item = raycast.get_collider()
		#interactive Item
		if item is itemClass:
			if not textChange:
				UI.setCollition(true)
				var text = item.getInteractive()
				UI.TextChanger(text)
				if Input.is_action_just_pressed("PickUp"):
					if ItemOnHand != "none":
						checkItemOnHand(item)
					else:
						showItemandUseItemInHand(item)
						
	else:
		UI.setCollition(false)


func checkItemOnHand(item):
	if item is Wrench and ItemOnHand == "Wrench":
		if !item.getOnTable():
			hideItemInHand(item)
			item.interactive()
			ItemOnHand = "none"
	else:
		UI.TextChanger("Hand are Full")
		textChange = true
		await get_tree().create_timer(0.8).timeout
		textChange = false

func showItemandUseItemInHand(item: itemClass) -> void:
	var inputItem = item.get_item_name()
	
	if inputItem == "Box":
		return
	
	if inputItem == "Wrench":
		wrenchHand.visible = true
	elif inputItem == "Fuse":
		fuseHand.visible = true
	#elif inputItem == "Key":
		#keyHand.visible = true
	ItemOnHand = inputItem
	item.interactive()

func hideItemInHand(item: itemClass) -> void:
	if ItemOnHand == "Wrench":
		wrenchHand.visible = false
	elif ItemOnHand == "Fuse":
		fuseHand.visible = false
	#elif ItemOnHand == "Key":
		#keyHand.visible = false


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


	
