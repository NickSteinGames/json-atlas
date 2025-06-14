@tool
@icon("json_atlas.svg")
extends AtlasTexture
## Draws an [member AtlastTexture] based on a given [Texture2D] [member texture] and it's
## associated [JSON] [member json_file].
class_name JSONAtlasTexture

## Signal emitted once the [member frames] and [member symbols] have been populated.
signal data_compiled

## The name of the Symbol that will be selected.
## [br]Set by [method set_symbol].
@export var symbol: String: set = set_symbol

## The [int] frame of the [member symbol] that will be rendered.
## [br]Set by [method set_frame].
@export var frame: int = 0: set = set_frame

## The source [Texture2D] image from which the image will be taken for output.
## [br]Set by [method set_texture]
@export var texture: Texture2D: set = set_texture

## The [Vector2] amount that the [member texture] will be scaled by.
## [br]Set by [method set_scale].
@export_custom(PROPERTY_HINT_LINK, "")
var scale: Vector2 = Vector2(1.0, 1.0):
	set = set_scale

## The [enum frame_behaviour_types] type of behaviour for [member frame] when it is set.
@export var frame_behaviour: frame_behaviour_types = frame_behaviour_types.STOP

## The [enum Image.Interpolation] behaviour for the scaling of the texture.
@export var scale_behaviour: Image.Interpolation = Image.Interpolation.INTERPOLATE_NEAREST

#region STORAGE
## [JSON] file with the atlas data for the [member texture].
## [br]Set by [method set_json_file].
@export_storage var json_file: JSON: set = _set_json_file

## A [PackedStringArray] that stores the [String] symbol names to be used within the animation.
@export_storage var symbols: PackedStringArray

## Stores the [Array] of [Rect2i] frames to be used within the animation.
@export_storage var frames: Dictionary#[String, Array[Rect2i]]

## The [ImageTexture] used as the [member AtlasTexture.atlas].
## Acts as the [member texture] with effects via [member scale] applied.
## [br]Set by [method _set_image]
@export_storage var _image: ImageTexture: set = _set_image
#endregion

## Enum to define the behaviour of out-of-bounds sets to [member frame].
enum frame_behaviour_types {
	## Clamp higher/lower values of the max/min when setting [member frame].
	STOP,
	## Loop the frames forward/backward. Setting [member frame] higher/lower than the max/min
	## will loop to the start/end.
	LOOP,
}

#region GET
## Returns the [int] number of frames in the given [String] [param symbol_name].
func get_frame_count(symbol_name: String = symbol) -> int:
	if !frames.has(symbol_name):
		return 0
	return frames[symbol_name].size()

## Creates a [String] hint-string of symbol names.
## [br]Used fo the [member symbol]'s export property, see [method _validate_property].
func _get_symbols_hint_string() -> String:
	return ",".join(symbols)

## Creates a [String] hint-string of frame titles.
## [br]Used for the [member frame]'s export property, see [method _validate_property].
func _get_frames_hint_string() -> String:
	return ",".join(frames.keys())
#endregion

#region SET
## Sets current [member symbol] to the given [String] [param new_symbol].
func set_symbol(new_symbol: String) -> void:
	if symbols.is_empty():
		await data_compiled
	if !symbols.has(new_symbol):
		if new_symbol != "":
			printerr("Symbol \""+new_symbol+"\" not found!")
		symbol = symbols.get(0)
		set_frame(frame)
		return
	symbol = new_symbol
	set_frame(frame)

## Set current [member frame] to the given [String] [param new_frame].
func set_frame(new_frame: int) -> void:
	if frames.is_empty():
		await data_compiled
	if new_frame > get_frame_count()-1:
		match frame_behaviour:
			frame_behaviour_types.LOOP:
				new_frame = 0
			_:
				new_frame = get_frame_count()-1
	if new_frame < 0:
		match frame_behaviour:
			frame_behaviour_types.LOOP:
				new_frame = get_frame_count()-1
			_:
				new_frame = 0
	frame = new_frame
	region = frames[symbol][frame]
	region.size *= scale
	region.position *= scale

## Sets [member _image] to the given [ImageTexture] [param new_image]
func _set_image(new_image: ImageTexture) -> void:
	_image = new_image
	atlas = _image

## Sets the [member texture] to the given [Texture2D] [param new_texture].
func set_texture(new_texture: Texture2D) -> void:
	texture = new_texture
	if new_texture:
		var path: String = texture.resource_path.replace(
			texture.resource_path.get_extension(),
			"json"
		)
		if FileAccess.file_exists(path):
			json_file = load(path)
			_update_image()
		else:
			printerr("JSON file for `%s` doesn`t exist!" % texture.resource_path.get_file())
	else:
		json_file = null
		symbols.clear()
		symbol = ""
		frame = 0
	notify_property_list_changed()

## Sets the [member json_file] to the given [JSON] [param given_file].
func _set_json_file(given_file: JSON) -> void:
	var old_json: JSON = json_file
	json_file = given_file
	if given_file:
		if !given_file.changed.is_connected(_update_json):
			given_file.changed.connect(_update_json)
		_load_json()
	else:
		old_json.changed.disconnect(_update_json)

## Sets the [member scale] to the given [Vector2] [param new_scale].
func set_scale(new_scale: Vector2) -> void:
	scale = new_scale
	_update_image()
#endregion

## Loads the [member json_file] and gets frame data.
func _load_json() -> void:
	if !json_file.data.has("frames"):
		printerr("Provided JSON file has no frame data!")
		return
	if !json_file.data is Dictionary:
		printerr("JSONAtlasTexture only supports Dictionaries!")
		return
	symbols.clear()
	frames.clear()
	var data: Dictionary = json_file.data
	for frameName: String in json_file.data.frames:
		var symbolName: String = frameName
		symbolName = symbolName.substr(0, symbolName.length()-4)
		# Flash exclusive for if you export an instanced symbol from the canvas instead of library
		#symbolName = symbolName.substr(0, frameName.findn(" instance"))
		if !symbols.has(symbolName):
			symbols.append(symbolName)
		if !frames.has(symbolName):
			frames[symbolName] = []
		var chunk: Dictionary = data.frames[frameName]
		frames[symbolName].append(Rect2i(
			chunk.frame.x,
			chunk.frame.y,
			chunk.frame.w,
			chunk.frame.h,
		))
	data_compiled.emit()

## Reloads the [member json_file] if changed.
func _update_json() -> void:
	json_file = load(json_file.resource_path)

## Updates the image displayed depending on the [member texture]
## and the [member scale].
func _update_image() -> void:
	if texture:
		var img: Image = texture.get_image().duplicate()
		img.resize(
			round(texture.get_width() * scale.x),
			round(texture.get_height() * scale.y),
			scale_behaviour
		)
		_image = ImageTexture.create_from_image(img)
	set_frame(frame)

func _validate_property(property: Dictionary) -> void:
	match property.name:
		"symbol":
			property.hint = PROPERTY_HINT_ENUM
			property.hint_string = _get_symbols_hint_string()
		"atlas", "region":
			property.usage = PROPERTY_USAGE_NO_EDITOR
