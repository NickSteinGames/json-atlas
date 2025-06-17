extends Object
class_name FastRegEx

static func search(pattern: String, subject: String, offset: int = 0, end: int = -1) -> RegExMatch:
	return RegEx.create_from_string(pattern).search(subject, offset, end)

static func search_all(pattern: String, subject: String, offset: int = 0, end: int = -1) -> Array[RegExMatch]:
	return RegEx.create_from_string(pattern).search_all(subject, offset, end)

static func sub(pattern: String, subject: String, replacement: String, all: bool = false, offset: int = 0, end: int = -1) -> String:
	return RegEx.create_from_string(pattern).sub(subject, replacement, all, offset, end)

static func get_gropu_count(pattern: String) -> int:
	return RegEx.create_from_string(pattern).get_group_count()

static func get_names(pattern: String) -> PackedStringArray:
	return RegEx.create_from_string(pattern).get_names()
