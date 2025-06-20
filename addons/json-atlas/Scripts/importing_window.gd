@tool
extends ConfirmationDialog

@export var file_line_edit: LineEdit
@export var dir_line_edit: LineEdit



@export var scale_container: BoxContainer

func _ready() -> void:
	show()
	scale_container.vertical = !EditorInterface.get_editor_settings().get_setting("interface/inspector/horizontal_vector2_editing")

func _on_select_file_button_pressed() -> void:
	var new_win = EditorFileDialog.new()
	new_win.access = EditorFileDialog.ACCESS_RESOURCES
	new_win.file_mode = EditorFileDialog.FILE_MODE_OPEN_FILE
	new_win.current_path = file_line_edit.text
	new_win.size = Vector2.ONE * 750
	new_win.add_filter("*.png", "PNG Pictures")
	new_win.add_filter("*.jpg, *.jpeg", "JPEG  Pictures")
	
	new_win.file_selected.connect(_on_inport_file_selected)
	
	EditorInterface.get_editor_main_screen().add_child(new_win)
	new_win.popup_centered()


func _on_select_dir_button_pressed() -> void:
	var new_win = EditorFileDialog.new()
	new_win.access = EditorFileDialog.ACCESS_RESOURCES
	new_win.file_mode = EditorFileDialog.FILE_MODE_OPEN_DIR
	new_win.current_path = dir_line_edit.text
	new_win.size = Vector2.ONE * 750
	
	new_win.dir_selected.connect(_on_inport_file_selected)
	
	EditorInterface.get_editor_main_screen().add_child(new_win)
	new_win.popup_centered()

func _on_inport_file_selected(path: String):
	pass

func _on_inport_dir_selected(path: String):
	pass


func _on_confirmed() -> void:
	queue_free()

func get_main_data() -> Dictionary:
	return {
		"save_dir":  dir_line_edit.get_text(),
		"frames_behaviour": AtlasTextureJSON.FrameBehaviourTypes.STOP
	}
