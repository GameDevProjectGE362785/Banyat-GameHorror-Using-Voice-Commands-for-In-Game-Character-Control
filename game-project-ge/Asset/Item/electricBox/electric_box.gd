
extends Node3D
class_name ElectricBox

@onready var status_light: OmniLight3D = get_node_or_null("StatusLight") as OmniLight3D
@onready var status_mesh: MeshInstance3D = get_node_or_null("StatusMesh") as MeshInstance3D

var powered := false

const REQUIRED_FUSES := 4
var inserted_fuses := 0


func _ready() -> void:
	_update_status()


func _process(_delta: float) -> void:
	# ตรวจว่าผ่าน Event ทั้งหมดแล้วหรือยัง
	if EventScheduler.fuseCheck:
		if EventScheduler.RunNumber \
		and EventScheduler.ShutDown \
		and EventScheduler.TollSort \
		and EventScheduler.DifColor \
		and EventScheduler.BoxCheck \
		and EventScheduler.Fix \
		and EventScheduler.GodangTwoCheck \
		and EventScheduler.CutOut:
			if has_node("MeshInstance3D"):
				$MeshInstance3D.visible = true
				

# ข้อความที่ Player จะได้รับเมื่อมองมาที่ ElectricBox
func getInteractive() -> String:
	if powered:
		return "Power Restored"
	$Electic.play()
	return "Insert Fuse (%d/%d)" % [inserted_fuses, REQUIRED_FUSES]

func interactive() -> void:
	pass  # ElecBox ไม่ต้องทำอะไรตรงนี้ ใช้ use_item() แทน
# ฟังก์ชันนี้ให้ Player เรียกใช้
# เช่น item.use_item("Fuse")
func use_item(item_name: String) -> bool:
	if EventScheduler.RunNumber \
		and EventScheduler.ShutDown \
		and EventScheduler.TollSort \
		and EventScheduler.DifColor \
		and EventScheduler.BoxCheck \
		and EventScheduler.Fix \
		and EventScheduler.GodangTwoCheck:
		$MeshInstance3D.visible = true
		$Main.visible = true # ปิดการควบคุมเมาส์ของ Player 
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE 
		print("ElectricBox: Enter Mini Game") 
		return true
	# ถ้าไฟกลับมาแล้ว ไม่สามารถใส่ Fuse เพิ่ม
	if powered:
		return false

	# ต้องเป็น Fuse เท่านั้น
	if item_name != "Fuse":
		return false

	# Fuse ครบแล้ว
	if inserted_fuses >= REQUIRED_FUSES:
		return false
	

	# ใส่ Fuse
	inserted_fuses += 1

	print("ElectricBox: Fuse %d/%d" % [
		inserted_fuses,
		REQUIRED_FUSES
	])


	# ตรวจว่า Fuse ครบหรือยัง
	if inserted_fuses >= REQUIRED_FUSES:
		$Cutout.play()
		powered = true
		$MeshInstance3D.visible = false
		print("ElectricBox: POWER RESTORED")
	
		# เปิดไฟสถานะ
		_update_status()

		# คืนไฟให้โรงงาน
		if has_node("/root/LightingSystem"):
			LightingSystem.restore_factory_power()

		# แจ้ง EventScheduler ว่าซ่อม Fuse เสร็จ
		EventScheduler.fuseCheck = true

	else:
		_update_status()

	return true


func _update_status() -> void:

	# ไฟสถานะ
	if is_instance_valid(status_light):
		status_light.visible = powered


	if not is_instance_valid(status_mesh):
		return


	var material := status_mesh.get_active_material(0)

	if material is StandardMaterial3D:

		var status_material := material as StandardMaterial3D

		if powered:

			# สีเขียว = ไฟกลับมาแล้ว
			status_material.albedo_color = Color(
				0.15,
				0.9,
				0.25
			)

			status_material.emission_enabled = true

			status_material.emission = Color(
				0.1,
				0.8,
				0.2
			)

		else:

			# สีแดง = ยังไม่มีไฟ
			status_material.albedo_color = Color(
				0.8,
				0.08,
				0.05
			)

			status_material.emission_enabled = false
