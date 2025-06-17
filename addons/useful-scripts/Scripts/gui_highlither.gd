@tool
extends SyntaxHighlighter
class_name Syntax
	
const COLORS = {
	normal = Color.BISQUE,
	string = Color.TAN,
	string_name = Color.CORAL,
	node_path = Color.CADET_BLUE,
	item = Color.AQUAMARINE,
}

const PATTERNS: PackedStringArray = [
	".?\".*?\"", ##String/StringName
	"^\".*?\"", ##NodePath
	"&?\".*?\":" ##Item
]

func _get_line_syntax_highlighting(line: int) -> Dictionary:
	var result: Dictionary[int, Dictionary]
	var text = get_text_edit().get_line(line)
	
	for reg_match: RegExMatch in FastRegEx.search_all(PATTERNS[0], text):
		if reg_match.strings[0].begins_with("&"):
			result.merge(make_color(reg_match.get_start(), reg_match.get_end(), COLORS.string_name), true)
		elif reg_match.strings[0].begins_with("^"):
			result.merge(make_color(reg_match.get_start(), reg_match.get_end(), COLORS.node_path), true)
		else:
			result.merge(make_color(reg_match.get_start(), reg_match.get_end(), COLORS.string), true)
	
	
	for reg_match: RegExMatch in FastRegEx.search_all(PATTERNS[2], text):
		result.merge(make_color(reg_match.get_start(), reg_match.get_end(), COLORS.item), true)
	
	
	if !result.has(0): result.merge({0: {"color": COLORS.normal}}, true)
	return result

func make_color(start: int, end: int, color: Color) -> Dictionary[int, Dictionary]:
	return {start: {"color": color}, end: {"color": COLORS.normal}}
