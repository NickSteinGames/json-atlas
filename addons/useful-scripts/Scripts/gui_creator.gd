extends Object
class_name GUICreator
## Creates [Control] Nodes from [Dictionary].
## 
## [b]Example:[/b] 
## [codeblock]
## func _ready() -> void:
##    add_child(GUICreator.create_gui({
##        &"RootBox": {
##            "type": &"HBoxContainer",
##            "is_root": true,
##        },
##        &"PrintButton": {
##            "type": &"Button",
##            "parent": "root",
##            "text": "Print \"Hi!\"'",
##            "pressed_callable": func(): print("Hieeeee!"), ## Lambda function.
##        },
##        &"QuitButton": {
##            "type": &"Button",
##            "parent": "root",
##            "text": "Quit",
##            "pressed_callable": get_tree().quit, ## Callable from 'SceneTree'.
##        },
##    }))
## [/codeblock]
## 
## You can see the parameters in the description of the make_* functions, but there are several global [param Parameters]:[br]
## ● [param is_root]: [bool] - Makes this element the root for all others (all elements without the [param parent] parameter will automatically be added to the [param root_control]). [b]Default: [code]false[/code][/b][br][br]
## ● [param parent]: [bool] - Defines the parent of this element and adds it to it. If you set the value to [code]"root"[/code], then the element will be added as a child node of the root element ([param root_control]). You can also set the [code]name[/code] of the [param root_control] as the value, this will be equivalent. [b]Default: [code]"root"[/code][/b][br][br]
## ● [param h_*/v_size_flags] (or [param horizontal_*]/[param vertical_size_flags]: [enum Control.SizeFlags] - Param for sets element's [member Control.size_flags_horizontal] and [member Control.size_flags_vertical].
## [b]Default: [constant Control.SIZE_FILL][/b][br][br]
## ● [param min_size]: [Vector2] - [member Control.custom_minimum_size]. [b]Default: [constant Vector2.ZERO][/b][br][br]
## ● [param properties]: [Dictionary][[StringName], [Variant]] - A parameter for setting other properties that are not processed by the [method  make_*] methods. I recommend using [StringName] ([code]&""[/code]) to increase performance. [b]Default: [code]{}[/code][/b][br][br]
## ● [param signals]: [Dictionary][[StringName], [Callable]] - A parameter for setting other signals that are not processed by the [method  make_*] methods. I recommend using [StringName] ([code]&""[/code]) to increase performance. [b]Default: [code]{}[/code][/b][br][br]
## ● [param script]: [String] - You can attach custom script. It's can be a code in like String or path to script file. [b]Default: [code]""[/code][/b][br][br]
##● [param ready_callable]: [Callable] - Calls when [signal Node.ready] is emited.[br][br]
## 

static var global_button_groups: Dictionary[StringName, ButtonGroup] = {}

## Returns [Control] ([param root_control]) from given [param data].[br]
## [b]Example:[/b] 
## [codeblock]
## func _ready() -> void:
##    add_child(GUICreator.create_gui({
##        &"RootBox": {
##            "type": &"HBoxContainer",
##            "is_root": true,
##        },
##        &"PrintButton": {
##            "type": &"Button",
##            "parent": "root",
##            "text": "Print \"Hi!\"'",
##            "pressed_callable": func(): print("Hieeeee!"), ## Lambda function.
##        },
##        &"QuitButton": {
##            "type": &"Button",
##            "parent": "root",
##            "text": "Quit",
##            "pressed_callable": get_tree().quit, ## Callable from 'SceneTree'.
##        },
##    }))
## [/codeblock]
##The [param owner] argument can be one of the following 3 options:[br]
##● [String]/[StringName] - The [member Node.owner] for each element will be set to the node whose name was passed;[br]
##● [Node] - The passed node (can be any class that inherits from [Node]) will be set as [member Node.owner] for all elements;[br]
##● [NodePath] - Path to the node (starting from [member SceneTree.root]).[br]
static func create_gui(data: Dictionary[StringName, Dictionary], owner = null, theme: Theme = null) -> Control:
	assert(!data.is_empty(), "'data' is empty!")
	var root_control: Control
	var result_data: Dictionary[StringName, Control]
	var print_debuging = data.erase("print_debug")
	
	for control: StringName in data.keys():
		var control_data: Dictionary = data[control]
		var control_type: StringName = control_data.get("type", &"Control")
		var new_control: Control
		new_control = ClassDB.instantiate(control_type)
		match control_type:
			&"Label": new_control = make_label(control, control_data)
			&"Button": new_control = make_button(control, control_data)
			&"BoxContainer", &"HBoxContainer", &"VBoxContainer": new_control = make_box_container(control_data)
			&"OptionButton": new_control = make_option_button(control, control_data)
			&"LineEdit": new_control = make_line_edit(control_data)
		
		new_control.size_flags_horizontal = control_data.get("h_size_flags", control_data.get("horizontal_size_flags", Control.SIZE_FILL))
		new_control.size_flags_vertical = control_data.get("v_size_flags", control_data.get("vertical_size_flags", Control.SIZE_FILL))
		
		if control_data.has("ready_callable"):
			new_control.ready.connect(control_data.get("ready_callable"))
		
		for control_property: StringName in control_data.get("properties", {}).keys():
			new_control.set(control_property, control_data.get("properties", {})[control_property])
		
		for control_signal: StringName in control_data.get("signals", {}).keys():
			var err: Error = new_control.connect(control_signal, control_data.get("signals", {})[control_signal])
			if err != OK: printerr("Singal '%s' not connected - %s" % [control_signal, error_string(err)])
		
		if control_data.has("script"):
			var script: Variant = control_data.get("script", "")
			if script is String:
				if script.is_absolute_path():
					new_control.set_script(load(script))
				else:
					var new_script = GDScript.new()
					new_script.source_code = script
					new_script.reload()
					new_control.set_script(new_script)
			elif script is Resource:
				new_control.set_script(script)
			else:
				assert(false, "parametr 'script' mut be a 'path' to file, 'source_code' of script or a script object it self.")
		
		new_control.name = control
		
		if control_data.get("is_root", data.keys()[0] == control):
			root_control = new_control
			result_data[&"root"] = new_control
			result_data[control] = new_control
			if print_debuging: print_debug("Root '%s' added!" % control)
		else:
			result_data[StringName(control_data.get("parent", &"root"))].add_child(new_control, true)
			result_data[control] = new_control
			if print_debuging: print_debug("Element '%s' added!" % control)
		
		if owner:
			if owner is StringName || owner is String:
				if result_data.has(StringName(owner)):
					if !control_data.is_root:
						new_control.owner = result_data[StringName(owner)]
			elif owner is Node:
				new_control.owner = owner
			elif owner is NodePath:
				new_control.owner = new_control.get_tree().root.get_node(owner)
			else:
				assert(false, "'owner' mut be a 'String'/'StringName' of 'data'`s already existens GUI Control, owner it self (and 'Node') or 'NodePath' to the owner Node (from 'root').")
		
		assert(root_control, "No root! Add in 'data' on fisrt place Control with parametr 'is_root' = 'true'")
		
	
	
	return root_control

static func save_gui_scene(data: Dictionary[StringName, Dictionary], save_path: String) -> Error:
	var scene: PackedScene = PackedScene.new()
	var pack_err = scene.pack(create_gui(data, &"root"))
	if pack_err != OK:
		printerr("GUICretor: Can`t pack scene: ", error_string(pack_err))
		return pack_err
	var save_err = ResourceSaver.save(scene, )
	printerr("GUICretor: Can`t save scene: ", error_string(save_err))
	return save_err

## Creates a [Button] (and [CheckBox], [CheckButton]).[br]
## Button's Parameters:[br]
## ● [param text]: [String] - Text on [Button]. [b]Default: [param name][/b] (see [member Button.text])[br][br]
## ● [param toggle_mode]: [bool] - Makes Button toggable. [b]Default: [code]false[/code][/b] (see [member BaseButton.toggle_mode])[br][br]
## ● [param start_pressed]: [bool] - Makes Button pressed by default. [b]Default: [code]false[/code][/b] (if [param toggle_mode] is [code]true[/code]) (see [member BaseButton.button_pressed])[br][br]
## ● [param toggled_callable]: [Callable] - [Callable] for connect to [signal BaseButton.toggled]. It can be a Lambda function. Must be given for button functionality. (if [param toggle_mode] is [code]true[/code]) (see [signal BaseButton.toggled])[br][br]
## ● [param pressed_callable]: [Callable] - [Callable] for connect to [signal BaseButton.pressed]. It can be a Lambda function. Must be given for button functionality. (if [param toggle_mode] is [code]false[/code]) (see [signal BaseButton.pressed])[br][br]
## [br][b]Warning:[/b] [param start_pressed] not call [param toggled_callable].
static func make_button(name:StringName, control_data: Dictionary) -> Button:
	var new_button: Button
	
	new_button = ClassDB.instantiate(control_data.type)
	
	new_button.text = control_data.get("text", name)
	new_button.toggle_mode = control_data.get("toggle_mode", false)
	if new_button.toggle_mode:
		new_button.button_pressed = control_data.get("start_pressed", false)
		if control_data.has("toggled_callable"):
			new_button.toggled.connect(control_data.get("toggled_callable"))
	else:
		if control_data.has("pressed_callable"):
			new_button.pressed.connect(control_data.get("pressed_callable"))
	
	return new_button

## Creates a [Label].[br]
## Label's Parameters:[br]
## ● [param text]: [String] - [member Label.text]. [b]Default: [param name][/b][br][br]
## ● [param h_*/v_alignment]: [String] -  [member Label.horizontal_alignment] and  [member Label.vertical_alignment]. You also can use [code]"horizontal_*"[/code] and [code]"vertical_alignment"[/code] for changing alignments.
## [b]Default: [constant HORIZONTAL_ALIGNMENT_LEFT]; [constant VERTICAL_ALIGNMENT_TOP][/b][br][br]
## ● [param clip_text]: [bool] - [member Label.clip_text]. [b]Default: [code]false[/code][/b][br][br]
## ● [param autowrap_mode] (or [param autowrap]): [enum TextServer.AutowrapMode] - [member Label.autowrap_mode]. [b]Default: [constant TextServer.AutowrapMode.AUTOWRAP_OFF][/b][br][br]
## ● [param overrun_behavior]: [enum TextServer.OverrunBehavior] - [member Label.text_overrun_behavior]. [b]Default: [constant TextServer.OVERRUN_NO_TRIMMING][/b][br][br]
## ● [param label_settings]: [LabelSettings] - [member Label.label_settings]. [b]Default: [code]null[/code][/b][br][br]
static func make_label(name:StringName, control_data: Dictionary) -> Label:
	var new_label = Label.new()
	
	new_label.text = control_data.get("text", "")
	new_label.horizontal_alignment = control_data.get("h_alignment", control_data.get("horizontal_alignment", HORIZONTAL_ALIGNMENT_LEFT))
	new_label.vertical_alignment = control_data.get("v_alignment", control_data.get("vertical_alignment", VERTICAL_ALIGNMENT_TOP))
	
	new_label.clip_text = control_data.get("clip_text", false)
	new_label.text_overrun_behavior = control_data.get("overrun_behavior", control_data.get("autowrap", TextServer.AutowrapMode.AUTOWRAP_OFF))
	
	new_label.autowrap_mode = control_data.get("autowrap_mode", TextServer.OverrunBehavior.OVERRUN_NO_TRIMMING)
	
	new_label.label_settings = control_data.get("label_settings", null)
	
	return new_label

## Creates a [RichTextLabel].[br]
## Label's Parameters:[br]
## ● as with [method make_label][br][br]
## ● [param bbcode_enebled]: [bool] - [member RichTextLabel.bbcode_enabled]. [b]Default: [code]false[/code][/b][br][br]
static func make_rich_label(control_data: Dictionary) -> RichTextLabel:
	var new_label = RichTextLabel.new()
	
	new_label.text = control_data.get("text", "")
	new_label.horizontal_alignment = control_data.get("h_alignment", control_data.get("horizontal_alignment", HORIZONTAL_ALIGNMENT_LEFT))
	new_label.vertical_alignment = control_data.get("v_alignment", control_data.get("vertical_alignment", VERTICAL_ALIGNMENT_TOP))
	
	new_label.clip_text = control_data.get("clip_text", false)
	new_label.text_overrun_behavior = control_data.get("overrun_behavior", TextServer.OverrunBehavior.OVERRUN_NO_TRIMMING)
	
	new_label.label_settings = control_data.get("label_settings", null)
	
	return new_label

## Creates a [BoxContainer] (or [HBoxContainer]/[VBoxContainer].[br]
## BoxContainer's Parameters:[br]
## ● [param vertical]: [bool] - [member BoxContainer.vertical]. [b]Default: [code]false[/code][/b][br][br]
## ● [param alignment]: [enum BoxContainer.AlignmentMode] - [member BoxContainer.alignment]. [b]Default: [constant BoxContainer.ALIGNMENT_BEGIN][/b][br][br]
## ● [param separation]: [int] - [theme_item BoxContainer.separation]. [b]Default: [code]4[/code][/b][br][br]
static func make_box_container(control_data: Dictionary) -> BoxContainer:
	var new_box: BoxContainer = BoxContainer.new()
	
	new_box.alignment = control_data.get("alignment", BoxContainer.ALIGNMENT_BEGIN)
	new_box.vertical = (control_data.type == &"VBoxContainer" || control_data.get("vertical", false)) && control_data.type != &"HBoxContainer"
	new_box.add_theme_constant_override("separation", control_data.get("separation", 4))
	
	return new_box

## Creates a [OptionButton].[br]
## OptionButton's Parameters:[br]
## ● as with [method make_button][br][br]
## ● [param items]: [Array][[Dictionary]] - items for [OptionButton]. (see [method OptionButton.add_item] and [method OptionButton.add_icon_item) [br][br]
## ● [param item_selected_callable]: [Callable] - Callalbe, whats [method Callable.call] when item selected. (see [signal OptionButton.item_selected]) [b]Default: [code]null[/code][/b][br][br]
## ● [param item_focused_callable]: [Callable] - Callalbe, whats [method Callable.call] when item focused. (see [signal OptionButton.item_focused]) [b]Default: [code]null[/code][/b][br][br]
## [b]Default: [code][][/code][/b] (see [method OptionButton.add_item] [br][br]
## [br]
## Items has Parameters:[br]
## ● [param text]: [String] - visible text for item. [b]Default: [code]""[/code][/b][br][br]
## ● [param id]: [int] - item's ID. [b]Default: [code]-1[/code][/b][br][br]
## ● [param icon]: [Texture2D] - icon item. (see [method OptionButton.add_icon_item]) [b]Default: [code]null[/code][/b][br][br]
## ● [param selected_callable]: [Callable] - Callalbe, whats [method Callable.call] when this item selected. (see [signal OptionButton.item_selected]) [b]Default: [code]null[/code][/b][br][br]
## ● [param focused_callable]: [Callable] - Callalbe, whats [method Callable.call] when this item focused. (see [signal OptionButton.item_focused]) [b]Default: [code]null[/code][/b][br][br]
## [b]Note:[/b] [code]Item[/code]'s [param selected_*] and [param focused_callable]s don't overrides a [b]OptionButton's[/b] parameter [param item_selected_*] and [param item_focused_callable]s.[br]
## [b]Note:[/b] if you put [code]separator:[/code] in begin of text and item become separator (see [method OptionButton.add_separator]
## [b]Warning:[/b] You don't need to make a Callable with arguments for [param selected_*] and [param focused_callable]s (for the [param index] of the original signals), theme functions are called DIRECTLY for each element individually.
## 
## [b]Example:[/b] 
## [codeblock]
## GUICreator.create_gui({
##        &"Root": {
##            "is_root": true
##        },
##        &"Button": {
##            "type": &"OptionButton",
##            "text": "Some Text",
##            "items": [
##                {
##                    "text": "Hello",
##                    "selected_callable": print.bind("Hello, I'am option \"Hello\"!"),
##                },
##                {
##                    "text": "separator:Separator #1!",
##                },
##                {
##                    "text": "I dunno",
##                    "selected_callable": print.bind("Idk who iam..."),
##                },
##            ],
##            "item_selected_callable": func(id: int): print("Option selected: ", id)
##        }
##    }))
## [/codeblock]
static func make_option_button(name:StringName, control_data: Dictionary) -> OptionButton:
	var new_button: OptionButton = make_button(name, control_data)
	
	if control_data.has("item_selected_callable"):
		new_button.item_selected.connect(control_data.get("item_selected_callable"))
	if control_data.has("item_focused_callable"):
		new_button.item_focused.connect(control_data.get("item_focused_callable"))
	
	var items: Array = control_data.get("items", [])
	for item: Dictionary in items:
		if item.get("text").begins_with("separator:"):
			new_button.add_separator(item.get("text", "").replace("separator:", ""))
		else:
			if item.has("icon"):
				new_button.add_icon_item(item.get("icon", null), item.get("text", ""), item.get("id", -1))
			else:
				new_button.add_item(item.get("text", ""), item.get("id", -1))
			
			if item.has("selected_callable"):
				new_button.item_selected.connect(
					(func(index: int):
						if index == items.find(item):
							(item.get("selected_callable") as Callable).call()
							)
					)
			if item.has("focused_callable"):
				new_button.item_focused.connect(
					(func(index: int):
						if index == items.find(item):
							(item.get("focused_callable") as Callable).call()
							)
					)
	
	return new_button

##Creates a [LineEdit].[br]
##LineEdit's Parameters:[br]
## ● [param default_text]: [String] - Text by defualt (see [member LineEdit.text]). [b]Default: [code]""[/code][/b][br][br]
## ● [param placeholder_text] (or [param placeholder]): [String] - Text what be displayed if [member LineEdit.text] is empty. (see [member LineEdit.placeholder_text]) [b]Default: [code]""[/code][/b][br][br]
## ● [param text_changed_callable]: [Callable] - Calls when [member LineEdit.text] is changed.[br][br]
## ● [param text_submitted_callable]: [Callable] - Calls when [member LineEdit.text] is submitted (user presse [code]"ui_accept"[/code]).[br][br]
static func make_line_edit(control_data: Dictionary) -> LineEdit:
	var line_edit = LineEdit.new()
	
	line_edit.placeholder_text = control_data.get("placeholder_text", control_data.get("placeholder", ""))
	line_edit.text = control_data.get("default_text", "")
	
	if control_data.has("text_changed_callable"):
		line_edit.text_changed.connect(control_data.get("text_changed_callable"))
	if control_data.has("text_submitted_callable"):
		line_edit.text_submitted.connect(control_data.get("text_submitted_callable"))
	
	return line_edit

##Creates a [TextEdit].[br]
##TextEdit's Parameters:[br]
## ● [param default_text]: [String] - Text by defualt (see [member LineEdit.text]). [b]Default: [code]""[/code][/b][br][br]
## ● [param placeholder_text] (or [param placeholder]): [String] - Text what be displayed if [member LineEdit.text] is empty. (see [member LineEdit.placeholder_text]) [b]Default: [code]""[/code][/b][br][br]
## ● [param text_changed_callable]: [Callable] - Calls when [signal TextEdit.text_changed] is emitted.[br][br]
static func make_text_edit(control_data: Dictionary) -> TextEdit:
	var line_edit = TextEdit.new()
	
	line_edit.placeholder_text = control_data.get("placeholder_text", control_data.get("placeholder", ""))
	line_edit.text = control_data.get("default_text", "")
	
	if control_data.has("text_changed_callable"):
		line_edit.text_changed.connect(control_data.get("text_changed_callable"))
	
	return line_edit
