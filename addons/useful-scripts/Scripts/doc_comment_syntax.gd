@tool
extends SyntaxHighlighter
class_name DocCommentSyntaxHighlighter

const NORMAL_COLOR: Color = Color.WHEAT


const COLORS = {
	"ClassColor": Color.SPRING_GREEN * 1.1,
	"annotation": Color.ORANGE,
	"constant": Color.AQUAMARINE,
	"enum": Color.CRIMSON,
	"member": Color.DARK_GRAY,
	"method": Color.DARK_CYAN,
	"constructor": Color.PALE_GREEN,
	"operator": Color.BLANCHED_ALMOND,
	"theme_item": Color.DARK_SLATE_BLUE,
	"param": Color.SKY_BLUE,
	
	"bbcode": Color.CADET_BLUE,
	"bbcode_code": Color.INDIAN_RED,
	"bbcode_url": Color.CYAN,
}
const BR_COLOR = Color.DIM_GRAY

const ONES_TAG_PATTERN = "\\[(.*?)[ ]?(\\S*?)\\]"
const TAG_PATTERN = "\\[(.*?)\\].*?\\[\\/.*?\\]"

const CLASSES: PackedStringArray = [
	"AABB",
	"Array",
	"Basis",
	"bool",
	"Callable",
	"Color",
	"Dictionary",
	"float",
	"int",
	"NodePath",
	"PackedByteArray",
	"PackedColorArray",
	"PackedFloat32Array",
	"PackedFloat64Array",
	"PackedInt32Array",
	"PackedInt64Array",
	"PackedStringArray",
	"PackedVector2Array",
	"PackedVector3Array",
	"PackedVector4Array",
	"Plane",
	"Projection",
	"Quaternion",
	"Rect2",
	"Rect2i",
	"RID",
	"Signal",
	"String",
	"StringName",
	"Transform2D",
	"Transform3D",
	"Vector2",
	"Vector2i",
	"Vector3",
	"Vector3i",
	"Vector4",
	"Vector4i",
]

func _get_line_syntax_highlighting(line: int) -> Dictionary:

	var result: Dictionary[int, Dictionary] = {}
	var line_text = get_text_edit().get_line(line)
	var class_list: PackedStringArray = get_text_edit().owner.class_list
	class_list.append_array(CLASSES)
	
	for reg_match: RegExMatch in FastRegEx.search_all(ONES_TAG_PATTERN, line_text):
		if reg_match.strings[1] in COLORS:
			result.merge(make_column_color(reg_match.get_start(), reg_match.get_end(), COLORS[reg_match.strings[1]]), true)
		elif reg_match.strings[2] in class_list:
			result.merge(make_column_color(reg_match.get_start(), reg_match.get_end(), COLORS["ClassColor"]), true)
		#elif reg_match.strings[2] == "br":
			#result.merge(make_column_color(reg_match.get_start(), reg_match.get_end(), BR_COLOR), true)
	
	for reg_match in FastRegEx.search_all(TAG_PATTERN, line_text):
		match reg_match.strings[1]:
			"code":
				result.merge(make_column_color(reg_match.get_start(), reg_match.get_end(), COLORS["bbcode_code"]), true)
			_:
				if reg_match.strings[1].begins_with("color"):
					var color: PackedStringArray = reg_match.strings[1].split("=")
					result.merge(make_column_color(reg_match.get_start(), reg_match.get_end(), Color.from_string(color[1], COLORS.bbcode)), true)
				if reg_match.strings[1].begins_with("url"):
					result.merge(make_column_color(reg_match.get_start(), reg_match.get_end(), COLORS.bbcode_url), true)
				result.merge(make_column_color(reg_match.get_start(), reg_match.get_end(), COLORS["bbcode"]), true)
	
	if result.has(0): result.merge({0: {"color": NORMAL_COLOR}}, true)
	return result

func make_column_color(start: int, end: int, color: Color) -> Dictionary:
	return {start: {"color": color}, end: {"color": NORMAL_COLOR}}
