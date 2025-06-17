@tool
extends HBoxContainer

@export var tag: String:
	set(v): tag = v; if tag_label: tag_label.text = v
@export_multiline var discription: String:
	set(v): discription = v; if desc_label: desc_label.text = v

@export var tag_label: Label
@export var desc_label: Label

func _ready() -> void:
	tag_label.text = tag
	desc_label.text = discription

func _draw() -> void:
	draw_rect(
		Rect2(
			Vector2.ZERO,
			size
		),
		Color(1, 1, 1, 0.23)
	)

func _on_button_pressed() -> void:
	DisplayServer.clipboard_set(tag.replace("\\n", "\n"))
