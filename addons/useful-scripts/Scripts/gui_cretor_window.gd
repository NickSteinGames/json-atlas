@tool
extends Window

@onready var line_edit: LineEdit = $PanelContainer/BoxContainer/BoxContainer/BoxContainer/LineEdit
@onready var data_edit: CodeEdit = $PanelContainer/BoxContainer/PanelContainer/DataEdit

var data

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_file_button_pressed() -> void:
	var new_win = EditorFileDialog.new()
	new_win.file_mode = EditorFileDialog.FILE_MODE_SAVE_FILE
	new_win.access = EditorFileDialog.ACCESS_RESOURCES
	new_win.size = Vector2.ONE * 750
	new_win.add_filter("*.tscn")
	new_win.add_filter("*.scn")
	new_win.add_filter("*.res")
	
	new_win.current_file = line_edit.text if line_edit.text else "res://gui.tscn"
	new_win.file_selected.connect(line_edit.set_text.bind())
	
	EditorInterface.popup_dialog_centered(new_win)
	GUICreator.create_gui({})

func _on_copy_button_pressed() -> void:
	DisplayServer.clipboard_set("")


func _on_save_button_pressed() -> void:
	var scene = PackedScene.new()
	scene.pack(data)
