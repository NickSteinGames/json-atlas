@tool
extends HBoxContainer

var import: bool = true
var symbol: StringName = ""

@onready var check_box: CheckBox = $CheckBox
@onready var spin_box_from: SpinBox = $SpinBox
@onready var spin_box_to: SpinBox = $SpinBox2


func get_data() -> Dictionary[StringName, Variant]:
	return {
		&"symbol": symbol,
		&"import": import,
		&"frames": [spin_box_from.value, spin_box_to.value],
	}

func _on_spin_box_value_changed(value: float) -> void:
	spin_box_to.min_value = value


func _on_spin_box_2_value_changed(value: float) -> void:
	spin_box_to.max_value = value


func _on_check_box_toggled(toggled_on: bool) -> void:
	import = toggled_on


func _on_check_box_2_toggled(toggled_on: bool) -> void:
	spin_box_from.editable = !toggled_on
	spin_box_to.editable = !toggled_on
