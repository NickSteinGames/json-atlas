@tool
extends ConfirmationDialog

@export var file_line_edit: LineEdit
@export var dir_line_edit: LineEdit
@export var extention_selector: OptionButton
@export var filename_pattern_line_edit: LineEdit
@export var frames_behaviour_selector: OptionButton
@export var ignoring_pattern_line_edit: LineEdit
@export var preview_rich_lable: RichTextLabel
@export var file_err_label: Label
@export var symbols_import_togglers: VBoxContainer
@export var all_symbols_imported_button: CheckBox

var source_image: Texture2D
var json: JSON
var source_atlas: AtlasTextureJSON
var paths = ["", ""]
var symbols_params: Dictionary[String, Dictionary] = {}
var ignor_pattern_ci = true
var not_import: PackedStringArray
var buttons: Dictionary[String, SymbolImportingButton]

const FILES_EXTENTIONS = [
	".tres",
	".res",
	".atlastex",
]

class SymbolImportingButton extends CheckBox:
	var symbol: String
	
	signal SymbolToggled(toggle_on: bool, symbol: String)
	
	func _init(p_symbol: String) -> void:
		symbol = p_symbol
		name = p_symbol
		text = " " + p_symbol + " "
		button_pressed = true
	
	func _toggled(toggled_on: bool) -> void:
		SymbolToggled.emit(toggled_on, symbol)

func _ready() -> void:
	show()
	var update_func = func(_v): update_symbols()
	extention_selector.item_selected.connect(update_func)
	filename_pattern_line_edit.text_changed.connect(update_func)
	frames_behaviour_selector.item_selected.connect(update_func)
	ignoring_pattern_line_edit.text_changed.connect(update_func)
	get_ok_button().disabled = true
	

func import():
	var symbol_num = 0
	for symbol: String in source_atlas.symbols:
		if !not_import.has(symbol):
			var symbol_atlas: AtlasTextureJSON = source_atlas.duplicate()
			symbol_atlas.set_symbol(symbol)
			var filename = get_filename(symbol)
			var path = "{dir}/{filename}{extention}".format({
				"dir": dir_line_edit.get_text(),
				"filename": filename,
				"extention": extention_selector.get_item_text(extention_selector.selected)
			})
			symbol_num += 1 
			var err = ResourceSaver.save(symbol_atlas, path)
			if err != OK:
				update_imported_text([symbol])
				break
	queue_free()

func update_symbols():
	get_ok_button().disabled = !(file_line_edit.text.is_absolute_path() && dir_line_edit.text.is_absolute_path())
	update_imported_text()
	for child in symbols_import_togglers.get_children(): child.queue_free()
	buttons.clear()
	for symbol in get_symbols():
		if !buttons.has(symbol):
			var new_button = SymbolImportingButton.new(symbol)
			new_button.SymbolToggled.connect(_on_symbol_import_toggled)
			buttons[symbol] = new_button
			symbols_import_togglers.add_child(new_button, true)

func get_main_data() -> Dictionary:
	return {
		"save_dir":  dir_line_edit.get_text(),
		"files_extention": FILES_EXTENTIONS[extention_selector.selected],
		"frames_behaviour": frames_behaviour_selector.selected,
	}

func set_preview_text(text: PackedStringArray):
	preview_rich_lable.text = ""
	for line in text:
		preview_rich_lable.text += line + "\n"

func update_params():
	pass

func get_symbols() -> PackedStringArray:
	return source_atlas.symbols

#region SIGNALS
func _on_select_file_button_pressed() -> void:
	var new_win = EditorFileDialog.new()
	new_win.access = EditorFileDialog.ACCESS_RESOURCES
	new_win.file_mode = EditorFileDialog.FILE_MODE_OPEN_FILE
	new_win.current_path = file_line_edit.text
	new_win.size = Vector2.ONE * 750
	new_win.add_filter("*.png", "PNG Pictures")
	new_win.add_filter("*.jpg, *.jpeg", "JPEG  Pictures")
	new_win.transient = true
	
	new_win.file_selected.connect(_on_inport_file_selected)
	
	add_child(new_win)
	new_win.popup_centered()


func _on_select_dir_button_pressed() -> void:
	var new_win = EditorFileDialog.new()
	new_win.access = EditorFileDialog.ACCESS_RESOURCES
	new_win.file_mode = EditorFileDialog.FILE_MODE_OPEN_DIR
	new_win.current_path = dir_line_edit.text
	new_win.size = Vector2.ONE * 750
	new_win.transient = true
	
	new_win.dir_selected.connect(_on_inport_dir_selected)
	
	add_child(new_win)
	new_win.popup_centered()


func _on_inport_file_selected(path: String):
	file_line_edit.text = path
	_on_file_line_edit_text_changed(path)
	update_symbols()

func _on_inport_dir_selected(path: String):
	dir_line_edit.text = path
	update_imported_text()
	update_symbols()

func _on_confirmed() -> void:
	import()

func _on_file_line_edit_text_changed(new_text: String) -> void:
	if new_text && FileAccess.file_exists(new_text):
		paths[0] = new_text
		paths[1] = new_text.replace(new_text.get_extension(), "json")
		
		if FileAccess.file_exists(paths[1]):
			source_image = load(paths[0])
			json = load(paths[1])
			
			var new_atlas = AtlasTextureJSON.new()
			new_atlas.set_texture(source_image)
			
			source_atlas = new_atlas
			file_err_label.hide()
			update_imported_text()
			return
		else:
			file_err_label.text = "Image file not have `.json` file!"
			file_err_label.show()
	set_preview_text([])

func _on_dir_line_edit_text_changed(new_text: String) -> void:
	update_symbols()

func _on_symbol_import_toggled(toggle_on: bool, symbol: String):
	if toggle_on:
		if not_import.find(symbol) != -1:
			not_import.remove_at(not_import.find(symbol))
	else:
		not_import.append(symbol)
	if not_import.is_empty(): all_symbols_imported_button.set_pressed_no_signal(true)
	else: all_symbols_imported_button.set_pressed_no_signal(false)
	get_ok_button().disabled = (not_import == get_symbols())
	update_imported_text()

#endregion

func update_imported_text(err_symbols: PackedStringArray = []):
	var text: PackedStringArray
	for symbol in source_atlas.symbols:
		if !not_import.has(symbol):
			var imported_symbol_line = "[color=white][b]{symbol}[/b][/color] [color=gray]- [hint=Frames Behaviour for this symbol]FB[/hint]: {fb} [/color] || [hint={file_path}]{file}[/hint]".format({
					"symbol": symbol,
					"fb": (AtlasTextureJSON.FrameBehaviourTypes.find_key(get_main_data().frames_behaviour) as String).capitalize(),
					"file": get_filename(symbol),
					"file_path": "{dir}/{filename}{extention}".format({
							"dir": dir_line_edit.get_text(),
							"filename": get_filename(symbol),
							"extention": extention_selector.get_item_text(extention_selector.selected)
						}),
				})
			if symbol in err_symbols:
				imported_symbol_line = "[bgcolor=#%s]" % Color(0.545098, 0, 0, 0.5).to_html() + imported_symbol_line + "[/bgcolor]"
			text.append(imported_symbol_line)
	set_preview_text(text)

func get_filename(symbol: String) -> String:
	var str = filename_pattern_line_edit.text.format({
			#region SOURCEFILE
			"sourcefile": source_atlas.texture.resource_path.get_file().replace("." + source_atlas.texture.resource_path.get_extension(), ""),
			"sourcefile:snake": source_atlas.texture.resource_path.get_file().replace("." + source_atlas.texture.resource_path.get_extension(), "").to_snake_case(),
			"sourcefile:camel": source_atlas.texture.resource_path.get_file().replace("." + source_atlas.texture.resource_path.get_extension(), "").to_camel_case(),
			"sourcefile:pascal": source_atlas.texture.resource_path.get_file().replace("." + source_atlas.texture.resource_path.get_extension(), "").to_pascal_case(),
			"sourcefile:upper": source_atlas.texture.resource_path.get_file().replace("." + source_atlas.texture.resource_path.get_extension(), "").to_upper(),
			"sourcefile:lower": source_atlas.texture.resource_path.get_file().replace("." + source_atlas.texture.resource_path.get_extension(), "").to_lower(),
			"sourcefile:capitalize": source_atlas.texture.resource_path.get_file().replace("." + source_atlas.texture.resource_path.get_extension(), "").capitalize(),
			#endregion
			
			#region SYMBOL
			"symbol": symbol,
			"symbol:snake": symbol.to_snake_case(),
			"symbol:camel": symbol.to_camel_case(),
			"symbol:pascal": symbol.to_pascal_case(),
			"symbol:upper": symbol.to_upper(),
			"symbol:lower": symbol.to_lower(),
			"symbol:capitalize": symbol.capitalize(),
			#endregion
			
			"symbolnum": source_atlas.symbols.find(symbol),
		})
	return str

func check_symbol(symbol: String) -> bool:
	var checks = !symbol.matchn(ignoring_pattern_line_edit.text) if ignor_pattern_ci else !symbol.match(ignoring_pattern_line_edit.text)
	if checks:
		if not_import.find(symbol) != -1:
			not_import.remove_at(not_import.find(symbol))
	else:
		not_import.append(symbol)
	
	return checks


func _on_all_check_box_toggled(toggled_on: bool) -> void:
	for button in symbols_import_togglers.get_children():
		if button is SymbolImportingButton:
			button.button_pressed = toggled_on


func set_ignor_pattern_ci(toggled_on: bool) -> void:
	ignor_pattern_ci = toggled_on
	update_symbols()
