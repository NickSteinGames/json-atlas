@tool
extends EditorPlugin

var atjson_submenu: PopupMenu

func _enter_tree() -> void:
	atjson_submenu = PopupMenu.new()
	add_tool_submenu_item("AtlasTextureJSON", atjson_submenu)
	atjson_submenu.id_pressed.connect(_on_atj_submenu_id_pressed)
	
	atjson_submenu.add_item("Import Frames", 0)
	atjson_submenu.set_item_tooltip(0, "Import all (or not) symbols and frames from one file into folder what you want.")

func _exit_tree() -> void:
	remove_tool_menu_item("AtlasTextureJSON")

func _on_atj_submenu_id_pressed(id: int):
	match id:
		0: open_json_import()
		_: pass

func open_json_import():
	const IMPORTING_WINDOW = preload("res://addons/json-atlas/Scenes/importing_window.tscn")
	var window = IMPORTING_WINDOW.instantiate()
	window.size = Vector2i(750, 500)
	EditorInterface.popup_dialog_centered(window)
	window.popup_centered()
