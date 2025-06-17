@tool
extends HSplitContainer

@export var param_text: String = "param": set = set_text
@export var param_type: ParamType: set = set_type
@export var param_tooltip: String = "":
	set(v): param_tooltip = v; text_button.tooltip_text = v
@export_group("Option", "option_")
@export var option_default: int = 0: set = set_option_default
@export var option_items: PackedStringArray: set = set_option_items
@export_group("Bool", "bool_")
@export var bool_default: bool
@export_group("String", "string_")
@export var string_default: String
@export var string_placeholder: String = "Text here..":
	set(v):
		string_placeholder = v
		if line_edit: line_edit.placeholder_text = v

@onready var option_button: OptionButton = $TabContainer/OptionButton
@onready var check_box: CheckBox = $TabContainer/CheckBox
@onready var line_edit: LineEdit = $TabContainer/LineEdit
@onready var text_button: Button = $Button

enum ParamType {
	OPTION,
	CHECK,
	STRING,
}

func _ready() -> void:
	option_button.select(option_default)
	_update()

func set_type(new_type: ParamType):
	param_type = new_type
	notify_property_list_changed()
	if option_button && check_box && line_edit:
		_update()

func set_text(new: String):
	param_text = new
	_update()

func set_option_default(new: int):
	option_default = new
	option_button.select(option_default)


func set_option_items(new: PackedStringArray):
	option_items = new
	if option_button:
		_update()
	

func _validate_property(property: Dictionary) -> void:
	if (property.name as String).begins_with("option_"):
		if param_type != ParamType.OPTION: property.usage = PROPERTY_USAGE_NO_EDITOR
	if (property.name as String).begins_with("bool_"):
		if param_type != ParamType.CHECK: property.usage = PROPERTY_USAGE_NO_EDITOR
	if (property.name as String).begins_with("string_"):
		if param_type != ParamType.STRING: property.usage = PROPERTY_USAGE_NO_EDITOR
	
	match property.name:
		"option_default":
			property.hint = PROPERTY_HINT_RANGE
			property.hint_string = "-1,%s,hide_slider" % [option_items.size() - 1]

func _update():
	text_button.text = param_text
	match param_type:
		ParamType.OPTION:
			option_button.show()
			option_button.clear()
			for item in option_items:
				option_button.add_item(item)
		ParamType.CHECK:
			check_box.show()
		ParamType.STRING:
			line_edit.show()
