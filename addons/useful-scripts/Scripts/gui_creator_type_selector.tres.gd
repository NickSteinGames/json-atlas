@tool
extends OptionButton

const class_list: PackedStringArray = [
	"Control",
	
	"sep:Containers",
	"BoxContainer",
	"HBoxContainer",
	"VBoxContainer",
	
	"MarginContainer",
	
	"Panel",
	"PanelContainer",
	
	"sep:Functionality Elements",
	"Button",
	"OptionButton",
	"LineEdit",
	"Label"
]

func _ready() -> void:
	clear()
	for clas in class_list:
		if clas.begins_with("sep:"):
			add_separator(clas.replace("sep:", ""))
		else:
			add_icon_item(AnyIcon.get_builtin_class_icon(clas), clas)
		
	select(0)
