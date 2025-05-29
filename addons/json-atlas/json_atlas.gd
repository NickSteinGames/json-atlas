@tool
extends AtlasTexture
## Draws an [member AtlastTexture] based on a given [Texture2D] [member source_image] and it's
## associated [JSON] [member json_file].
class_name JSONAtlasTexture

## The name of the Frame that will be rendered.
@export var frame: String: set = set_frame

@export_group("Data")
## The source [Texture2D] image from which the image will be taken for output.
@export var source_image: Texture2D: set = set_source_image
		
## [JSON] file with the atlas data for the [member source_image].
@export var json_file: JSON: set = set_json_file

## Stores the [Rect2i] frames to be used within the animation.
@export_storage var frames: Dictionary#[String, Rect2i]

## Sets the [member source_image] to the given [Texture2D] [param given_image].
func set_source_image(given_image: Texture2D) -> void:
	source_image = given_image
	atlas = given_image
	if given_image:
		var path: String = source_image.resource_path.replace(source_image.resource_path.get_extension(), "json")
		if FileAccess.file_exists(path):
			json_file = load(path)
		else:
			printerr("JSON file for `%s` doesn`t exist!" % source_image.resource_path.get_file())
	else:
		json_file = null
	notify_property_list_changed()

## Sets the [member json_file] to the given [JSON] [param given_file].
func set_json_file(given_file: JSON) -> void:
	var old_json: JSON = json_file
	json_file = given_file
	if !given_file.changed.is_connected(_update_json):
		given_file.changed.connect(_update_json)
	if given_file:
		_load_json()
	else:
		old_json.changed.disconnect(_update_json)

## Set current [member frame] to the given [String] [param new_frame].
func set_frame(new_frame: String) -> void:
	if !frames.has(new_frame):
		printerr("Frame \""+new_frame+"\" not found!")
		return
	frame = new_frame
	region = frames[frame]

## Loads the [member json_file] and gets frame data.
func _load_json() -> void:
	if !json_file.data.has("frames"):
		printerr("Provided JSON file has no frame data!")
		return
	if !json_file.data is Dictionary:
		printerr("JSONAtlasTexture only supports Dictionaries!")
		return
	frames.clear()
	var data: Dictionary = json_file.data
	for frm: int in json_file.data.frames:
		frames[frm] = Rect2i(
			data.frames[frm].frame.x,
			data.frames[frm].frame.y,
			data.frames[frm].frame.w,
			data.frames[frm].frame.h,
		)

## Creates a [String] hint-string of frame titles.
## [br]Used for the [member frame]'s export property, see [method _validate_property].
func _get_frames_hint_string() -> String:
	var result: String = ""
	for frm in frames.keys():
		if result:
			result += ",%s" % frm
		else:
			result = frm
	return result

## Reloads the [member json_file] if changed.
func _update_json() -> void:
	json_file = load(json_file.resource_path)

func _validate_property(property: Dictionary) -> void:
	match property.name:
		"frame":
			property.hint = PROPERTY_HINT_ENUM
			property.hint_string = _get_frames_hint_string()
		# Hiding default [AtlasTexture] properties.
		"atlas", "region":
			property.usage = PROPERTY_USAGE_NO_EDITOR
