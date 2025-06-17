@tool
@icon("atlas_texture_json.svg")
extends AtlasTexture
class_name AtlasTextureJSON
## Draws an [member AtlasTexture] based on a given [Texture2D] [member texture] and it's
## associated [JSON] [member json_file].
##
## [b]Notice:[/b] when exporting via Aseprite, ensure the [b]Item Filename[/b] is formatted as:
##[codeblock lang=text]
##{tag}{tagframe0000}
##[/codeblock]
##
## @tutorial(Adobe Animate sprite sheet export guide): https://www.adobe.com/africa/learn/animate/web/export-sprite-sheet
## @tutorial(Aseprite`s sprite sheets export formating): https://www.aseprite.org/docs/cli/#filename-format
##

## Signal emitted once the [member frames] and [member symbols] have been populated.
signal data_compiled

@export_tool_button("Update", "Edit") var _call_update = _update_all

## The name of the Symbol that will be selected.
## [br]Set by [method set_symbol].
@export var symbol: String = "": set = set_symbol

##if [code]true[/code], [AtlasTextureJSON] splits [param symbols] and [param symbol`s frame].[br]
##Its only find nums at end of [param Symbol name], and if your symbol has nums at end ([code]Frog01[/code], [code]Frog02[/code] eg.), its makes frames for first symbol with same name without nums at end (after removing "frames nums")[br]
@export var split_frames: bool = true: set = set_split_frames

## The [int] frame of the [member symbol] that will be rendered.
## [br]Set by [method set_frame].
@export var frame: int = 0: set = set_frame

## The source [Texture2D] image from which the image will be taken for output.
## [br]Set by [method set_texture]
@export var texture: Texture2D: set = set_texture

@export_group("Parameters")
## The [Vector2] amount that the [member texture] will be scaled by.
## [br]Set by [method set_scale].
@export_custom(PROPERTY_HINT_LINK, "")
var scale: Vector2 = Vector2(1.0, 1.0):
	set = set_scale

## The [enum FrameBehaviourTypes] type of behaviour for [member frame] when it is set.
@export var frame_behaviour: FrameBehaviourTypes = FrameBehaviourTypes.STOP

## The [enum Image.Interpolation] behaviour for the scaling of the texture.
@export var scale_behaviour: Image.Interpolation = Image.Interpolation.INTERPOLATE_NEAREST

@export_group("Debug")
@export var show_debug: bool:
	set(v): show_debug = v; notify_property_list_changed()
#region STORAGE
## [JSON] file with the atlas data for the [member texture].
## [br]Set by [method set_json_file].
@export var json_file: JSON: set = _set_json_file

## A [PackedStringArray] that stores the [String] symbol names to be used within the animation.
@export var symbols: PackedStringArray

## Stores the [Array] of [Rect2i] ([Vector4]) frames to be used within the animation.
@export var frames: Dictionary[StringName, PackedVector4Array]

## The [ImageTexture] used as the [member AtlasTexture.atlas].
## Acts as the [member texture] with effects via [member scale] applied.
## [br]Set by [method _set_image]
@export var _image: ImageTexture: set = _set_image
#endregion


## Enum to define the behaviour of out-of-bounds sets to [member frame].
enum FrameBehaviourTypes {
	## Clamp higher/lower values of the max/min when setting [member frame].
	STOP,
	## Loop the frames forward/backward. Setting [member frame] higher/lower than the max/min
	## will loop to the start/end.
	LOOP,
}

# Everything, whats starts with [get_*]/[_get_*].
#region GET
## Returns the [int] number of frames in the given [String] [param symbol_name].
func get_frame_count(symbol_name: String = symbol) -> int:
	if !frames.has(symbol_name):
		return 0
	return frames[symbol_name].size()

## Creates a [String] hint-string of symbol names.
## [br]Used fo the [member symbol]'s export property, see [method _validate_property].
func _get_symbols_hint_string() -> String:
	if !symbols.has(symbol):
		symbol = symbols[0]
	return ",".join(symbols)

## Creates a [String] hint-string of frame titles.
## [br]Used for the [member frame]'s export property, see [method _validate_property].
func _get_frames_hint_string() -> String:
	return ",".join(frames.keys())
#endregion

# Everything, whats starts with [set_*]/[_set_*].
#region SET
## Sets current [member symbol] to the given [String] [param new_ymbol].
func set_symbol(new_symbol: String) -> void:
	if symbols.is_empty():
		await data_compiled
	if !symbols.has(new_symbol):
		if new_symbol != "":
			printerr("Symbol `%s` not found!" % new_symbol)
		symbol = symbols.get(0)
		set_frame(frame)
		return
	symbol = new_symbol
	set_frame(frame)

## Set current [member frame] to the given [String] [param new_frame].
func set_frame(new_frame: int) -> void:
	if !frames.has(symbol):
		if symbols.is_empty():
			return
		symbol = symbol
	
	# Just wait...
	if frames.is_empty():
		await data_compiled
	
	# Checks frame_behaviour
	match frame_behaviour:
		FrameBehaviourTypes.LOOP:
			if new_frame < 0:
				new_frame = get_frame_count() - 1
			elif new_frame > get_frame_count() - 1:
				new_frame = 0
		_:
			if new_frame < 0:
				new_frame = 0
			elif new_frame > get_frame_count() - 1:
				new_frame = get_frame_count() - 1
	
	# Sets the values
	frame = new_frame
	region = vec4_to_rect2(frames[symbol][frame])
	region.size *= scale
	region.position *= scale

## Sets [member _image] to the given [ImageTexture] [param new_image]
func _set_image(new_image: ImageTexture) -> void:
	_image = new_image
	#_update_image()
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
		atlas = null
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
	scale.x = max(new_scale.x, 0.05)
	scale.y = max(new_scale.y, 0.05)
	_update_image()

## Sets the [member split_frames] to the given [bool] [param new].
func set_split_frames(new: bool):
	split_frames = new
	_update_json()
	notify_property_list_changed()

#endregion

#region UPDATERS
## Loads the [member json_file] and gets frame data.
func _load_json() -> void:
	if !json_file.data.has("frames"):
		printerr("Provided JSON file has no frame data!")
		return
	symbols.clear()
	frames.clear()
	var data: Dictionary = json_file.data
	for element: Variant in data.frames:
		var chunk: Dictionary
		var symbolName: String
		
		if data.frames is Dictionary:
			chunk = data.frames[element]
			symbolName = element
		
		if data.frames is Array:
			chunk = element
			symbolName = chunk["filename"]
		
		if split_frames:
			var serch =  RegEx.create_from_string("(?'frame'\\d*)$").search(symbolName)
			if serch:
				symbolName = symbolName.substr(0, symbolName.length() - (serch.strings[serch.names.frame] as String).length())
		
		if !symbols.has(symbolName):
			symbols.append(symbolName)
		if !frames.has(symbolName):
			frames[symbolName] = PackedVector4Array([])
		
		frames[symbolName].append(rect2_to_vec4(Rect2(
			chunk.frame.x,
			chunk.frame.y,
			chunk.frame.w,
			chunk.frame.h,
		)))
	data_compiled.emit()

## Reloads the [member json_file] if changed.
func _update_json() -> void:
	json_file = load(json_file.resource_path)

## Updates the image displayed depending on the [member texture]
## and the [member scale].
func _update_image() -> void:
	if texture:
		var img: Image = texture.get_image().duplicate()
		#img.get_region(vec4_to_rect2(frames[StringName(symbol)][frame]))
		img.resize(
			round(texture.get_width() * scale.x),
			round(texture.get_height() * scale.y),
			scale_behaviour
		)
		_image = ImageTexture.create_from_image(img)
	set_frame(frame)

func _update_all():
	_update_image()
	_update_json()
	set_symbol(symbol)

#endregion

func _validate_property(property: Dictionary) -> void:
	match property.name:
		"symbol":
			property.hint = PROPERTY_HINT_ENUM
			property.hint_string = _get_symbols_hint_string()
		"frame": if !split_frames: property.usage = PROPERTY_USAGE_NO_EDITOR
		"atlas", "region":
			if !show_debug:
				property.usage = PROPERTY_USAGE_NO_EDITOR

func vec4_to_rect2(vector: Vector4) -> Rect2:
	return Rect2(
		vector.x,
		vector.y,
		vector.z,
		vector.w,
	)

func rect2_to_vec4(rect: Rect2) -> Vector4:
	return Vector4(
		rect.position.x,
		rect.position.y,
		rect.size.x,
		rect.size.y
	)
