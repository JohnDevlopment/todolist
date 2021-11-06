extends VBoxContainer

signal edit_request(index, new_text)

var NewItem: LineEdit
var Submit: Button
var Cancel: Button

func _ready() -> void:
	NodeMapper.map_nodes(self)

func finish_edit(index: int, new_text: String):
	NewItem.text = ''
	emit_signal('edit_request', index, new_text)

func start_edit(index: int, text: String):
	set_meta('item_index', index)
	NewItem.text = text
	$WhichItem.bbcode_text = "Editing item [i]%d[/i]" % index

func _on_NewItem_text_entered(new_text: String) -> void:
	NewItem.release_focus()
	finish_edit(get_meta('item_index'), new_text)

func _on_Submit_pressed() -> void:
	finish_edit(get_meta('item_index'), NewItem.text)

func _on_Cancel_pressed() -> void:
	finish_edit(-1, '')
