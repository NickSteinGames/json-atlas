@tool
extends AtlasTexture
class_name JSONAtlasTexture

@export var frame: String: ## Frame, what be rendered.
	set = set_frame
@export_group("Data")
@export var source_image: Texture2D: ## The source image from which the image will be taken for output.
	set(v):
		source_image = v
		atlas = v
		if v:
			var path = source_image.resource_path.replace(
				source_image.resource_path.get_extension(),
				"json"
			)
			if FileAccess.file_exists(path):
				json_file = load(path)
			else:
				printerr("JSON file for `%s` doesn`t exist!" % source_image.resource_path.get_file())
		else: json_file = null
		notify_property_list_changed()
		
@export var json_file: JSON: ## JSON file with atlas data.
	set(v):
		var old_json: JSON = json_file
		json_file = v
		if !v.changed.is_connected(_update_json):
			v.changed.connect(_update_json)
		if v: _load_json()
		else: old_json.changed.disconnect(_update_json)
		

@export_storage var frames: Dictionary

## Loads JSON and gets a Frames data.
func _load_json():
	if json_file.data.has("frames"):
		if json_file.data is Dictionary:
			frames.clear()
			var data: Dictionary = json_file.data
			for frm in json_file.data.frames:
				frames[frm] = Rect2i(
					data.frames[frm].frame.x,
					data.frames[frm].frame.y,
					data.frames[frm].frame.w,
					data.frames[frm].frame.h,
				)
		else:
			printerr("JSONAtalsTexture not supported `Array`!")
	else:
		printerr("JSON file has`t frames data!")

## Set current frame.
func set_frame(new_frame: String):
	if frames.has(new_frame):
		frame = new_frame
		region = frames[frame]

## Just make enum of frames. (only for `frame`)
func _get_frames_enum() -> String:
	var result: String
	for frm in frames.keys():
		if result: result += ",%s" % frm
		else: result = frm
	
	return result

func _validate_property(property: Dictionary) -> void:
	match property.name:
		"frame":
			property.hint = PROPERTY_HINT_ENUM
			property.hint_string = _get_frames_enum()
		"atlas", "region": property.usage = PROPERTY_USAGE_NO_EDITOR ## Just hide default [AtlasTexture] properties.

## If your json has been updated.
func _update_json():
	json_file = load(json_file.resource_path)
