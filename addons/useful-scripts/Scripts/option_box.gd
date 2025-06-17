@tool
extends HBoxContainer

@export var text: String = "Option":
	set(v): text = v; $Label.text = v
@export_enum("GuideCreator") var section: String = "GuideCreator"
@export var key: StringName
@export var value_type: ValueType = ValueType.NUMBER:
	set(v): value_type = v; notify_property_list_changed(); show_control()
@export var default_num_value: float = 0
@export var default_string_value: String = ""
@export var default_option_value: int = -1
@export var default_bool_value: bool = false
@export_group("Nodes", "node_")
@export var node_num_edit: Control
@export var node_string_edit: Control
@export var node_option_edit: Control
@export var node_bool_edit: Control
@export_group("Number", "num_")
@export var num_min_val: float = 10.0:
	set(v): num_min_val = v; if node_num_edit: node_num_edit.min_value = v
@export var num_max_val: float = 10.0:
	set(v):
		num_max_val = v
		if node_num_edit: node_num_edit.max_value = v
@export var num_step: float = 1.0:
	set(v): 
		num_step = floorf(v) if num_is_float else v
		if node_num_edit: node_num_edit.step = num_step
@export var num_is_float: bool = false:
	set(v): num_is_float = v; num_step = num_step
@export_group("Option", "option_")
## Possible values.[br]
## [code]{item_text}:{item_value}[/code][br]
## [b]Example item:[/b] item:0, item1:Hieeee!
@export var option_items: PackedStringArray = []

@onready var nodes: Dictionary[ValueType, Control] = {
	ValueType.NUMBER: node_num_edit,
	ValueType.STRING: node_string_edit,
	ValueType.OPTION: node_option_edit,
	ValueType.BOOL: node_bool_edit,
}
const SETS_PROPERTY = {
	ValueType.NUMBER: &"value",
	ValueType.STRING: &"text",
	ValueType.OPTION: &"selected",
	ValueType.BOOL: &"button_pressed",
}

var _section: StringName

enum ValueType {
	NUMBER,
	STRING,
	OPTION,
	BOOL
}

signal Edited(section: StringName, key: StringName, value)

func _ready() -> void:
	show_control()
	_section = section
	
	for item in option_items:
		$TabContainer/OptionButton.add_item(item.split(":")[0])
	
	if owner:
		get_crnt_type_node().set(SETS_PROPERTY[value_type], owner.config.get_value(_section, key, get_default()))
	

func get_value() -> Variant:
	return get_crnt_type_node().get(SETS_PROPERTY[value_type])

func edit(value):
	#Edited.emit(section, key, value)
	pass

func _validate_property(property: Dictionary) -> void:
		match property.name:
			"default_num_value": if value_type != ValueType.NUMBER: property.usage = PROPERTY_USAGE_NO_EDITOR
			"default_string_value": if value_type != ValueType.STRING: property.usage = PROPERTY_USAGE_NO_EDITOR
			"default_option_value": if value_type != ValueType.OPTION: property.usage = PROPERTY_USAGE_NO_EDITOR
			"default_bool_value": if value_type != ValueType.BOOL: property.usage = PROPERTY_USAGE_NO_EDITOR
		if property.name.begins_with("num_"):
			if value_type != ValueType.NUMBER:
				property.usage = PROPERTY_USAGE_NO_EDITOR
			if property.name == "num_step":
				property.type
		elif property.name.begins_with("option_"):
			if value_type != ValueType.OPTION:
				property.usage = PROPERTY_USAGE_NO_EDITOR
		elif property.name.begins_with("node_"):
			if EditorInterface.get_edited_scene_root() != self:
				property.usage = PROPERTY_USAGE_NO_EDITOR
		


func _on_option_button_item_selected(index: int) -> void:
	var item = option_items[index].split(':')
	if item.size() > 1:
		edit(item[1])
	else:
		edit(item[0])

func show_control():
	get_crnt_type_node().show()

func get_default() -> Variant:
	var result
	match value_type:
		ValueType.NUMBER: result = default_num_value
		ValueType.STRING: result = default_string_value
		ValueType.OPTION: result = default_option_value
		ValueType.BOOL: result = default_bool_value
	
	return result

func get_crnt_type_node() -> Control:
	var result: Control
	match value_type:
		ValueType.NUMBER: result = node_num_edit
		ValueType.STRING: result = node_string_edit
		ValueType.OPTION: result = node_option_edit
		ValueType.BOOL: result = node_bool_edit
	
	return result
