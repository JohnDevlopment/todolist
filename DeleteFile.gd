tool
extends WindowDialog

var FileTree: Tree
var WarningLabel: RichTextLabel
var DeleteButton: Button
var CancelButton: Button

signal files_deleted(files)

export var popup_size := Vector2(300, 300)

const DIR_PREFIX := 'user://'

var files: PoolStringArray

var _selected_items := []

func _enter_tree() -> void:
	if Engine.editor_hint:
		show()

func _ready() -> void:
	if Engine.editor_hint: return
	NodeMapper.map_nodes(self)
	_list_files()
	
	# HACK: show dialog while testing this
#	call_deferred('show_dialog')

func show_dialog():
	popup_centered(popup_size)

func _show_warning():
	FileTree.hide()
	WarningLabel.show()
	DeleteButton.hide()
	CancelButton.text = 'Exit'

func _list_files():
	var dir := Directory.new()
	files = PoolStringArray()
	
	if dir.open('user://') == OK:
		var root := FileTree.create_item()
		
		dir.list_dir_begin(false, true)
		
		var file_name: String = dir.get_next()
		
		# Append files to array
		while file_name != '':
			if not dir.current_is_dir() and file_name.get_extension().to_lower() == 'json':
				file_name = file_name
				files.append(DIR_PREFIX + file_name)
				
				var item := FileTree.create_item(root)
				item.set_text(0, file_name)
				item.set_text(1, DIR_PREFIX)
			
			file_name = dir.get_next()
	
	if files.empty():
		_show_warning()

func _on_FileTree_multi_selected(item: TreeItem, column: int, selected: bool) -> void:
	if column == 0:
		var value := item
		
		if selected:
			_selected_items.append(value)
		else:
			_selected_items.erase(value)

func _on_DeleteButton_pressed() -> void:
	if _selected_items.empty():
		$AcceptDialog.dialog_text = 'No files are selected.'
		$AcceptDialog.call_deferred('popup_centered')
		return
	
	files = PoolStringArray()
	
	var dialog_text := "You have selected these files to be deleted: %s. Do you want to remove them?"
	
	for item in _selected_items:
		var values := {
			file = (item as TreeItem).get_text(0),
			directory = (item as TreeItem).get_text(1)
		}
		
		var file: String = values.directory.plus_file(values.file)
		files.append(file)
	
	dialog_text = dialog_text % files.join(', ')
	
	$ConfirmationDialog.dialog_text = dialog_text
	$ConfirmationDialog.popup_centered(Vector2(458, 100))

func _on_ConfirmationDialog_confirmed() -> void:
# warning-ignore:unused_variable
	var dir := Directory.new()
	
	for file in files:
		dir.remove(file)
	
	emit_signal('files_deleted', files)
	
	queue_free()

func _on_CancelButton_pressed() -> void:
	queue_free()
