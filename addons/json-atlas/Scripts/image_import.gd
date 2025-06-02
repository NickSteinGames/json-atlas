@tool
extends EditorImportPlugin

func _get_importer_name():
	return "atlas.json"

func _get_visible_name():
	return "Texture JSON Atlas"

func _get_recognized_extensions():
	return ["png", "jpeg", "jpg", "webp"]

func _get_save_extension():
	return "png"

func _get_resource_type():
	return "ImageTexture"

func _get_preset_count():
	return 1

func _get_preset_name(preset_index):
	return "Default"

func _get_import_options(path, preset_index):
	return [{"name": "my_option", "default_value": false}]

func _get_option_visibility(path: String, option_name: StringName, options: Dictionary) -> bool:
	return true

func _import(source_file, save_path, options, platform_variants, gen_files):
	var file = FileAccess.open(source_file, FileAccess.READ)
	if file == null:
		return FAILED
	var mesh = ArrayMesh.new()
	# Заполните сетку данными, считанными из «файла», оставленного в качестве упражнения для читателя.

	var filename = save_path + "." + _get_save_extension()
	return ResourceSaver.save(mesh, filename)
