@tool
extends Control

func _ready() -> void:
	global_position = get_global_mouse_position()

func _on_rich_text_label_meta_clicked(meta: Variant) -> void:
	meta = str(meta)
	if meta.begins_with("mtd:"):
		EditorInterface.get_script_editor().goto_help(meta)
	else:
		DisplayServer.clipboard_set("meta")
