extends VBoxContainer

signal item_selected(index)
signal item_activated(index)

onready var todo_items: ItemList = $TodoItems

export var enabled := false setget set_enabled

class Comparison:
	static func _string_comp(a: Dictionary, b: Dictionary) -> bool:
		# both or neither are checked, so use string comparison
		
		var size : int = int( min(a.text.length(), b.text.length()) )
		var a_trunc : String = (a.text as String).substr(0, size)
		var b_trunc : String = (b.text as String).substr(0, size)
		
		var cmp : int = a_trunc.casecmp_to(b_trunc)
		if cmp == 0:
			cmp = (a.text as String).casecmp_to(b.text)
		if cmp <= 0:
			return true
		
		return false
	
	# return true if a comes before b
	static func sort_function(a: Dictionary, b: Dictionary) -> bool:
		assert('text' in a && 'finished' in a)
		assert('text' in b && 'finished' in b)
		
		# A is checked but not B
		if a.finished and not b.finished:
			return true
		# B is checked but not A
		elif b.finished and not a.finished:
			return false
		
		return _string_comp(a, b)

# options = {
#   icon = Texture,
#   modulate = Color
# }
func add_item(text: String, options: Dictionary = {}):
	var i: int = todo_items.get_item_count()
	todo_items.add_item(text)
	
	if 'icon' in options:
		todo_items.set_item_icon(i, options.icon)
		
		if options.icon and 'modulate' in options:
			todo_items.set_item_icon_modulate(i, options.modulate)

func clear_items() -> void:
	$TodoItems.clear()

func get_array() -> Array:
	var result := []
	
	if enabled:
		for i in todo_items.get_item_count():
			var item_text = todo_items.get_item_text(i)
			var icon = todo_items.get_item_icon(i)
			result.push_back({
				text = item_text if item_text is String else 'No text available',
				finished = true if icon != null else false
			})
	
	return result

func get_item_icon(index: int):
	return todo_items.get_item_icon(index)

func get_item_text(index: int):
	return todo_items.get_item_text(index)

func get_item_list() -> ItemList: return todo_items

func remove_checked() -> void:
	var items := get_array()
	clear_items()
	for item in items:
		if not item.finished:
			_add_todo_item(item.text)

func remove_item(index: int) -> void:
	assert(index >= 0)
	todo_items.remove_item(index)

func set_enabled(value: bool) -> void:
	enabled = value
	$AddItem/ItemName.editable = value
	$AddItem/AddItemButton.disabled = !value
	todo_items.self_modulate = Color.white if value else Color(0.917647, 0.929412, 0.72549)

func set_item_params(index: int, options: Dictionary) -> void:
	assert(index >= 0)
	
	if 'icon' in options:
		todo_items.set_item_icon(index, options.icon)
		
		if options.icon and 'modulate' in options:
			todo_items.set_item_icon_modulate(index, options.modulate)
	
	if 'text' in options and not (options.text as String).empty():
		todo_items.set_item_text(index, options.text)

func sort_items(options := {}) -> void:
	assert('icon' in options and options.icon is Texture, "options dictionary needs an icon texture")
	assert('modulate' in options and options.modulate is Color, "options dictionary needs a modulation color")
	
	var items := get_array()
	clear_items()
	items.sort_custom(self.Comparison, 'sort_function')
	for item in items:
		var _options := {}
		if item.finished:
			_options["icon"] = options.icon
			_options["modulate"] = options.modulate
		add_item(item.text, _options)

# Internals

func _add_todo_item(text: String):
	add_item(text, {})
	$AddItem/ItemName.text = ''

# Signals

func _on_TodoItems_item_activated(index: int) -> void:
	if not enabled: return
	emit_signal('item_activated', index)

func _on_TodoItems_item_selected(index: int) -> void:
	if not enabled: return
	emit_signal('item_selected', index)

func _on_AddItemButton_pressed() -> void:
	if not enabled: return
	_add_todo_item($AddItem/ItemName.text)

func _on_ItemName_text_entered(new_text: String) -> void:
	if not enabled: return
	_add_todo_item(new_text)
