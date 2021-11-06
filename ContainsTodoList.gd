extends VBoxContainer

signal item_selected(index)
signal item_activated(index)

onready var todo_items: ItemList = $TodoItems

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

func remove_item(index: int) -> void:
	assert(index >= 0)
	todo_items.remove_item(index)

func set_item_params(index: int, options: Dictionary) -> void:
	assert(index >= 0)
	
	if 'icon' in options:
		todo_items.set_item_icon(index, options.icon)
		
		if options.icon and 'modulate' in options:
			todo_items.set_item_icon_modulate(index, options.modulate)
	
	if 'text' in options and not (options.text as String).empty():
		todo_items.set_item_text(index, options.text)

# Internals

func _add_todo_item(text: String):
	add_item(text, {})
	$AddItem/ItemName.text = ''

# Signals

func _on_TodoItems_item_activated(index: int) -> void:
	emit_signal('item_activated', index)

func _on_TodoItems_item_selected(index: int) -> void:
	emit_signal('item_selected', index)

func _on_AddItemButton_pressed() -> void:
	_add_todo_item($AddItem/ItemName.text)

func _on_ItemName_text_entered(new_text: String) -> void:
	_add_todo_item(new_text)
