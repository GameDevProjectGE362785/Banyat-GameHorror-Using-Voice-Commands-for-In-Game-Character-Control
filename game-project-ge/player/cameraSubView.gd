extends Camera3D

@onready var cam = $"../../../CameraController"

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	Vector3 rotatevalue = cam.get_rotation() 
	
