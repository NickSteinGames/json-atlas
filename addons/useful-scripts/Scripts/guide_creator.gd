@tool
extends Window
class_name GuideCreator
##WIndow for more comfortable way create documentation comments.
##
##It auto replaced [code]\n[/code] (new lines) with [code][br][/code] (BBCode`s [param brake line]).[br]
##Guide Creator also has mini help list with all tags for documentation comments.[br]
##Window dont block you from main Editor`s GUI (how it doing another sub-windows), what gives you MORE comfortable expirience![br]
##[br]
##Oh, and, this all writed in this editor without any edditing in Sript Editor![br]
##[br]
##@tutorial(BBCode in Doc.comments): https://docs.godotengine.org/en/4.4/tutorials/scripting/gdscript/gdscript_documentation_comments.html

@export var code_edit: CodeEdit
@export var code_preview: CodeEdit
@export var font_size_box: SpinBox

var class_list: PackedStringArray

var CONFIG_FILE = EditorInterface.get_editor_paths().get_config_dir() + "/UsefulSecripsConfig.cfg"
var config: ConfigFile = ConfigFile.new()

func _ready() -> void:
	var config_err: Error = config.load(CONFIG_FILE)
	if config_err != OK:
		config.save(CONFIG_FILE)
	
	uptdate_options()
	
	code_edit.set_code_completion_prefixes(["["])
	
	class_list = ClassDB.get_class_list()


func get_text() -> String:
	var code_text: String = code_edit.get_text()
	var result_text: String = ""
	var codeblock: bool = false
	var first_line_added = false
	var ignor_next = true
	
	for line: String in code_text.split("\n"):
		if line.is_empty():
			if codeblock:
				line = "##\n"
			elif ignor_next:
				line = "##\n"
				ignor_next = false 
			else:
				line = "##[br]\n"
		else:
			
			
			ignor_next = line.ends_with("[ignor]") || line.ends_with("[ig]")
			if line.contains("[codeblock]") && !codeblock: codeblock = true
			if line.contains("[/codeblock]") && codeblock: codeblock = false
			
			if ignor_next: line = line.replace("[ig]", ""); line = line.replace("[ignor]", "")
			
			
			if line.contains("[/codeblock]") || line.contains("@tutorial") ||\
			line.contains("@deprecated") || line.contains("@experimental"):
				line = line + "\n"
			else:
				if !codeblock: line = line + ("[br]\n" if (!ignor_next && !codeblock) else "\n")
			
			if codeblock: line += "\n"
			
			if !line.begins_with("##"): line = "##" + line
			
			line = line.replace("\t", " ".repeat(get_value("TabSpaces", 4)))
		result_text += line
	
	if code_text.is_empty(): return ""
	
	if result_text.ends_with("\n"): result_text = result_text.erase(max(result_text.length() - 1, 0))
	
	return result_text

func _unhandled_input(event: InputEvent) -> void:
	
	if event is InputEventMouseButton:
		if event.is_pressed() && event.button_index == MOUSE_BUTTON_WHEEL_UP && event.ctrl_pressed:
			_on_plus_button_pressed()
		if event.is_pressed() && event.button_index == MOUSE_BUTTON_WHEEL_DOWN && event.ctrl_pressed:
			_on_minus_pressed()

func _input(event: InputEvent) -> void:
	if event.is_action("ui_cancel"):
		hide()

func _on_copy_button_pressed() -> void:
	DisplayServer.clipboard_set(get_text())


func _on_code_edit_text_changed() -> void:
	code_preview.text = get_text()
	#print(get_text())

func get_value(key: StringName, default = null):
	var _config = ConfigFile.new(); _config.load(CONFIG_FILE)
	return _config.get_value("GuideCreator", key, default)


func edit(section, key, value):
	config.set_value(section, key, value)
	config.save(CONFIG_FILE)
	uptdate_options()

func uptdate_options():
	var settings = EditorInterface.get_editor_settings()
	code_edit.use_custom_word_separators = settings.get_setting("text_editor/behavior/navigation/use_custom_word_separators")
	code_edit.custom_word_separators = settings.get_setting("text_editor/behavior/navigation/custom_word_separators")
	
	code_edit.indent_size = get_value("TabSpaces", 4)
	
	code_edit.draw_tabs = get_value("ShowTabs", false)
	
	code_edit.draw_spaces = get_value("ShowSpaces", false)
	code_preview.draw_spaces = get_value("ShowSpaces", false)
	
	_on_code_edit_text_changed()

func _on_spin_box_value_changed(value: float) -> void:
	code_edit.add_theme_font_size_override("font_size", int(value))
	code_preview.add_theme_font_size_override("font_size", int(value))


func _on_minus_pressed() -> void:
	font_size_box.value -= font_size_box.step * 2

func _on_plus_button_pressed() -> void:
	font_size_box.value += font_size_box.step * 2
