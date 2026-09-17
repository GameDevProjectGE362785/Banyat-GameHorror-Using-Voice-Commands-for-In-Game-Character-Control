@tool
extends Node3D

## แก้หัวข้อและรายการกฎได้ตรงนี้ หรือแก้ใน Inspector หลังเลือกโหนดนี้ในฉาก
## (ใช้ \n ขึ้นบรรทัดใหม่ในข้อความกฎ)
@export_multiline var title_text: String = "กฎระเบียบบริษัท":
	set(value):
		title_text = value
		_apply_text()

@export_multiline var rules_text: String = "1. มาทำงานตรงเวลา\n2. แต่งกายสุภาพเรียบร้อย\n3. รักษาความสะอาดพื้นที่ทำงาน\n4. ห้ามสูบบุหรี่ในอาคาร\n5. ปิดเครื่องจักร/อุปกรณ์หลังใช้งานเสร็จทุกครั้ง\n6. สวมอุปกรณ์นิรภัยทุกครั้ง\n7. รายงานอุบัติเหตุทันที\n8. เคารพเพื่อนร่วมงาน":
	set(value):
		rules_text = value
		_apply_text()

@onready var title_label: Label3D = $TitleLabel
@onready var rules_label: Label3D = $RulesLabel


func _ready() -> void:
	_apply_text()


func _apply_text() -> void:
	if title_label:
		title_label.text = title_text
	if rules_label:
		rules_label.text = rules_text
