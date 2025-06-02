@tool
extends EditorImportPlugin

var json: JSON

func _get_importer_name():
	return "atlas.json"

func _get_visible_name():
	return "Texture JSON Atlas"

func _get_recognized_extensions() -> PackedStringArray:
	return PackedStringArray(["png", "jpeg", "jpg", "webp"])

func _get_save_extension() -> String:
	return "res"

func _get_resource_type() -> String:
	return "JSONAtlasTexture"

func _get_preset_count() -> int:
	return 1

func _get_preset_name(preset_index: int):
	return "Default"

func _get_import_options(path: String, preset_index: int):
	get_json(path)
	return [
		{
			"name": "folder",
			"default_value": path.get_base_dir() + "/" + path.get_file().replace("." + path.get_extension(), ""),
			"property_hint": PROPERTY_HINT_DIR,
		},
		{
			"name": "image_scale",
			"default_value": 1.0,
			"property_hint": PROPERTY_HINT_RANGE,
			"hint_string": "1.0, 10.0, 0.01,or_greater",
		},
		{
			"name": "ignoring_pattern",
			"default_value": "",
			"property_hint": PROPERTY_HINT_RANGE,
			"hint_string": "1.0, 10.0, 0.01,or_greater",
		},
		{
			"name": "ignoring_frames",
			"default_value": [],
			"property_hint": PROPERTY_HINT_TYPE_STRING,
			"hint_string": "%d/%d:%s" % [TYPE_STRING, PROPERTY_HINT_ENUM, _get_frames_hint_string()],
		},
	]

func _get_option_visibility(path: String, option_name: StringName, options: Dictionary) -> bool:
	return true

func _import(source_file: String, save_path: String, options: Dictionary, platform_variants: Array[String], gen_files: Array[String]) -> Error:
	var result: Array[JSONAtlasTexture]
	var source_image: ImageTexture = load(source_file)
	var imported_frames: PackedStringArray = PackedStringArray(json.data.frames.keys())
	for frame in options.ignoring_frames:
		imported_frames.remove_at(imported_frames.find(frame))
	
	for frame in imported_frames:
		var atlas = JSONAtlasTexture.new()
		atlas.source_image = source_image
		atlas.source_image_scale = options.image_scale
		atlas.set_frame(frame)
		
		result.append(atlas)
	
	for atlas in result:
		var err = ResourceSaver.save(atlas, options.folder + ("/%s.tres" % [atlas.frame.to_snake_case()]))
		if err != OK:
			return err
	
	return OK

func _get_priority() -> float:
	return 1.0

func get_json(path: String):
	json = load(path.replace(
		path.get_extension(),
		"json"
	))

func _get_frames_hint_string() -> String:
	var result: String = ""
	
	for frame: String in json.data.frames:
		if result: result += ",%s" % frame
		else: result = frame
	
	return result
