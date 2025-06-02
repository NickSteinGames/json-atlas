@tool
extends EditorPlugin

var image_import: EditorImportPlugin

func _enter_tree() -> void:
	image_import = preload("res://addons/json-atlas/Scripts/image_import.gd").new()
	add_import_plugin(image_import)


func _exit_tree() -> void:
	remove_import_plugin(image_import)
