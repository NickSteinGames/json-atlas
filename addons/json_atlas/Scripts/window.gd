extends Window

func _ready() -> void:
	files_dropped.connect(_on_files_droped)

func _on_files_droped(files: PackedStringArray):
	print(JSON.stringify(files, "\t"))
