extends Panel

export var check_color: Color

enum FileMenuID {
	CHOOSE_FILE,
	SAVE,
	DELETE_FILES,
	GET_USER_DIRECTORY,
	CLOSE_FILE,
	QUIT
}

enum EditMenuID {
	EDIT_ITEM,
	DELETE_ITEM,
	SORT_ITEMS,
	DELETE_CHECKED
}

const INVALID_VALUE: int = 0xffffffff
const CONFIG_FILE := 'user://todolist.cfg'

onready var Resources: ResourcePreloader = get_node("Resources")
onready var FileMenuButton: MenuButton = get_node("Margin/MainColumn/Menu/FileMenuButton")
onready var EditMenuButton: MenuButton = get_node("Margin/MainColumn/Menu/EditMenuButton")
onready var TodoItems: VBoxContainer = get_node("Margin/MainColumn/MainTabs/$TodoItems")
onready var ModifyItem: VBoxContainer = get_node("Margin/MainColumn/MainTabs/$ModifyItem")
onready var MainTabs: TabContainer = get_node("Margin/MainColumn/MainTabs")
onready var StatusLabel: Label = get_node("Margin/MainColumn/StatusBar/StatusLabel")

var config := {'data_file': 'user://todo_items.json'}
var data_file_loaded := false

var _current_item := -1

func _ready() -> void:
	_build_file_menu()
	_build_edit_menu()
	
	# Read config file
	if FileHelpers.file_exists(CONFIG_FILE):
		_load_config()
	else:
		_save_config()
	
	_read_data_file()
	
	# Display status message depending on whether the file exists and was loaded
	if data_file_loaded:
		StatusLabel.call_deferred("display_status", 3, "Successfully loaded '%s'" % config.data_file)
	elif config.data_file != '':
		StatusLabel.call_deferred("display_status", 3, "'%s' does not exist; will create a new file" % config.data_file)
	else:
		StatusLabel.call_deferred("display_status", 3, 'No file loaded')
	
	# Connect todo item list
	(TodoItems.get_item_list() as ItemList).connect('nothing_selected', self, '_on_TodoItems_nothing_selected')

func _build_file_menu():
	var menu := FileMenuButton.get_popup()
	menu.connect('id_pressed', self, '_on_file_menu_id_pressed')
	
	menu.add_item("Choose File <Ctrl+o>", FileMenuID.CHOOSE_FILE)
	menu.set_item_shortcut(menu.get_item_index(FileMenuID.CHOOSE_FILE), _create_shortcut(KEY_O, {control = true}))
	
	menu.add_item("Save File <Ctrl+s>", FileMenuID.SAVE)
	menu.set_item_shortcut(menu.get_item_index(FileMenuID.SAVE), _create_shortcut(KEY_S, {control = true}))
	
	menu.add_separator()
	
	menu.add_item("Delete Files", FileMenuID.DELETE_FILES)
	
	menu.add_item("Get User Directory", FileMenuID.GET_USER_DIRECTORY)
	
	menu.add_separator()
	
	menu.add_item("Close File <Ctrl+w>", FileMenuID.CLOSE_FILE)
	menu.set_item_shortcut(menu.get_item_index(FileMenuID.CLOSE_FILE), _create_shortcut(KEY_W, {control = true}))
	
	menu.add_item("Quit <Alt+F4>", FileMenuID.QUIT)

func _build_edit_menu():
	var menu := EditMenuButton.get_popup()
	menu.connect('id_pressed', self, '_on_edit_menu_id_pressed')
	
	menu.add_item("Edit Item")
	menu.set_item_shortcut(menu.get_item_index(EditMenuID.EDIT_ITEM), _create_shortcut(KEY_E, {}))
	
	menu.add_item("Delete Item")
	menu.set_item_shortcut(menu.get_item_index(EditMenuID.DELETE_ITEM), _create_shortcut(KEY_DELETE, {}))
	
	menu.add_item("Sort Items")
	
	menu.add_item("Delete Checked Items")

func _exit_tree() -> void:
	_save_data_file()
	_save_config()

func _create_shortcut(key: int, mods: Dictionary, is_physical: bool = true) -> ShortCut:
	var sc := ShortCut.new()
	var event := InputEventKey.new()
	
	if is_physical:
		event.physical_scancode = key
	else:
		event.scancode = key
	
	# Set mods in event
	for mod in ['control', 'shift', 'alt', 'meta', 'command']:
		if mod in mods:
			event.set(mod, mods[mod])
	
	sc.shortcut = event
	
	return sc

func _delete_entry() -> void:
	if _current_item >= 0:
		TodoItems.remove_item(_current_item)
		_on_TodoItems_nothing_selected()
	else:
		StatusLabel.display_status(3, 'Select an item first')

func _edit_item() -> void:
	if _current_item >= 0:
		ModifyItem.start_edit(_current_item, TodoItems.get_item_text(_current_item))
		MainTabs.set_deferred('current_tab', 1)
	else:
		StatusLabel.display_status(3, 'Select an item first')

func _delete_checked_entries() -> void:
	TodoItems.remove_checked()

# Data files

func _no_file_loaded() -> void:
	TodoItems.set_enabled(false)
	var file_menu: PopupMenu = FileMenuButton.get_popup()
	file_menu.set_item_disabled(file_menu.get_item_index(FileMenuID.CLOSE_FILE), true)
	file_menu.set_item_disabled(file_menu.get_item_index(FileMenuID.SAVE), true)
	
	EditMenuButton.disabled = true

func _file_loaded() -> void:
	TodoItems.set_enabled(true)
	var file_menu: PopupMenu = FileMenuButton.get_popup()
	file_menu.set_item_disabled(file_menu.get_item_index(FileMenuID.CLOSE_FILE), false)
	file_menu.set_item_disabled(file_menu.get_item_index(FileMenuID.SAVE), false)
	
	EditMenuButton.disabled = false

func _close_data_file() -> void:
	# Save file before closing
	if config.data_file != '':
		_save_data_file()
		StatusLabel.display_status(3, "'%s' has been saved...closing now" % config.data_file)
	
	TodoItems.clear_items()
	config.data_file = ''
	data_file_loaded = false
	_no_file_loaded()

func _read_data_file() -> void:
	TodoItems.set_enabled(true)
	TodoItems.clear_items()
	data_file_loaded = false
	
	if config.data_file == '':
		_no_file_loaded()
		return
	
	# Read list file
	var list_data = FileHelpers.read_json_file(config.data_file)
	if list_data is Array:
		for dict in list_data:
			var icon = Resources.get_resource('check') if dict.finished else null
			TodoItems.add_item(dict.text, {
				icon = icon,
				modulate = check_color
			})
	
	data_file_loaded = true
	_file_loaded()
	StatusLabel.display_status(3, "Set data file to '%s'" % config.data_file)

func _save_data_file() -> void:
	if not data_file_loaded: return
	var item_list: Array = TodoItems.get_array()
	FileHelpers.write_json_file(config.data_file, item_list)

# Config file

func _load_config():
	var config_file := ConfigFile.new()
	
	var err := config_file.load(CONFIG_FILE)
	if err: return err
	
	var value = config_file.get_value('', 'data_file', INVALID_VALUE)
	if value is String:
		config.data_file = value

func _save_config():
	var config_file := ConfigFile.new()
	config_file.set_value('', 'data_file', config.data_file)
	
	var err := config_file.save(CONFIG_FILE)
	if err:
		$AcceptDialog.dialog_text = "Failed to open 'user://%s'." % config.data_file
		$AcceptDialog.popup_centered()

# Signals

func _on_file_menu_id_pressed(index: int) -> void:
	match index:
		FileMenuID.CHOOSE_FILE:
			# Choose new file
			$FileDialog.popup_centered_ratio(0.85)
		FileMenuID.SAVE:
			# Save current file
			_save_data_file()
			StatusLabel.display_status(3, "Saved file: " + config.data_file)
		FileMenuID.DELETE_FILES:
			# Delete file dialog
			var dlg: Control = load('res://DeleteFile.tscn').instance()
			add_child(dlg)
			dlg.connect('files_deleted', self, '_on_deletefile_files_deleted')
			dlg.show_dialog()
		FileMenuID.CLOSE_FILE:
			# Close current file
			_close_data_file()
		FileMenuID.QUIT:
			# Quit
			get_tree().quit()
		FileMenuID.GET_USER_DIRECTORY:
			# Get user directory
			OS.clipboard = OS.get_user_data_dir()
			StatusLabel.display_status(3, "User data directory added to the clipboard")

func _on_edit_menu_id_pressed(id: int) -> void:
	match id:
		EditMenuID.EDIT_ITEM:
			_edit_item()
		EditMenuID.DELETE_ITEM:
			if _current_item >= 0:
				StatusLabel.display_status(3, "Deleted Item %d" % _current_item)
				TodoItems.remove_item(_current_item)
				_on_TodoItems_nothing_selected()
			else:
				StatusLabel.display_status(3, 'Select an item first')
		EditMenuID.DELETE_CHECKED:
			TodoItems.remove_checked()
			StatusLabel.display_status(3, 'Removed Checked Items')
		EditMenuID.SORT_ITEMS:
			TodoItems.sort_items({icon = Resources.get_resource('check'), modulate = check_color})
			StatusLabel.display_status(3, 'Sorted Items')

func _on_FileDialog_file_selected(path: String) -> void:
	config.data_file = path
	_read_data_file()

func _on_ModifyItem_edit_request(index: int, new_text: String) -> void:
	MainTabs.current_tab = 0
	
	if index >= 0 and not new_text.empty():
		TodoItems.set_item_params(index, {text = new_text})

# Checks if the current file is among the ones deleted
func _on_deletefile_files_deleted(files: PoolStringArray):
	if config.data_file in files:
		config.data_file = ''
		_close_data_file()

# TodoItems signals

func _on_todo_item_selected(index: int) -> void:
	_current_item = index

func _on_todo_item_activated(index: int) -> void:
	_current_item = index
	
	var icon = TodoItems.get_item_icon(_current_item)
	if not icon:
		icon = Resources.get_resource('check')
	else:
		icon = null
	
	TodoItems.set_item_params(_current_item, {
		icon = icon,
		modulate = check_color
	})

func _on_TodoItems_nothing_selected() -> void:
	_current_item = -1

func _on_FileDialog_about_to_show() -> void:
	$FileDialog.call_deferred('invalidate')
