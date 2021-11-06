extends Panel

export var check_color: Color

const INVALID_VALUE: int = 0xffffffff
const CONFIG_FILE := 'user://todolist.cfg'

var TodoItems: Control
var Resources: ResourcePreloader
var StatusLabel: Label
var ItemName: LineEdit
var FileMenuButton: MenuButton
var MainTabs: TabContainer
var ModifyItem: Control

var config := {'data_file': 'user://todo_items.json'}

var _current_item := -1

func _ready() -> void:
	NodeMapper.map_nodes(self)
	
	# Read config file
	if FileHelpers.file_exists(CONFIG_FILE):
		load_config()
	else:
		save_config()
	
	_read_data_file()
	
	FileMenuButton.get_popup().connect('index_pressed', self, '_on_File_menu_index_pressed')
	
	(TodoItems.get_item_list() as ItemList).connect('gui_input', self, '_on_TodoItems_gui_input')
	(TodoItems.get_item_list() as ItemList).connect('nothing_selected', self, '_on_TodoItems_nothing_selected')
	
	# Display status message depending on whether the file exists and was loaded
	if get_meta('data_file_loaded'):
		StatusLabel.display_status(3, "Successfully loaded '%s'" % config.data_file)
	else:
		StatusLabel.display_status(3, "'%s' does not exist; will create a new file" % config.data_file)

func _exit_tree() -> void:
	_save_data_file()
	save_config()

func _read_data_file() -> void:
	TodoItems.clear_items()
	set_meta('data_file_loaded', false)
	
	# Read list file
	var list_data = FileHelpers.read_json_file(config.data_file)
	if list_data is Array:
		for dict in list_data:
			var icon = Resources.get_resource('check') if dict.finished else null
			TodoItems.add_item(dict.text, {
				icon = icon,
				modulate = check_color
			})
		set_meta('data_file_loaded', true)

func _save_data_file() -> void:
	var item_list: Array = TodoItems.get_array()
	FileHelpers.write_json_file(config.data_file, item_list)

func load_config():
	var config_file := ConfigFile.new()
	
	var err := config_file.load(CONFIG_FILE)
	if err: return err
	
	var value = config_file.get_value('', 'data_file', INVALID_VALUE)
	if value is String:
		config.data_file = value
	
	print("Data file: ", config.data_file)

func save_config():
	var config_file := ConfigFile.new()
	config_file.set_value('', 'data_file', config.data_file)
	
	var err := config_file.save(CONFIG_FILE)
	if err:
		$AcceptDialog.dialog_text = "Failed to open 'user://%s'." % config.data_file
		$AcceptDialog.popup_centered()

# Signals: TodoItems

func _on_File_menu_index_pressed(index: int) -> void:
	match index:
		0:
			$FileDialog.popup_centered_ratio(0.85)
		1:
			_save_data_file()
			StatusLabel.display_status(2, "Saved file: " + config.data_file)

func _on_FileDialog_file_selected(path: String) -> void:
	config.data_file = path
	_read_data_file()
	StatusLabel.display_status(3, "Set data file to '%s'" % path)

func _on_ModifyItem_edit_request(index: int, new_text: String) -> void:
	MainTabs.current_tab = 0
	
	if index >= 0 and not new_text.empty():
		TodoItems.set_item_params(index, {text = new_text})

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

func _on_TodoItems_gui_input(event: InputEvent) -> void:
	if event is InputEventKey:
		match event.scancode:
			KEY_DELETE:
				if _current_item >= 0:
					TodoItems.remove_item(_current_item)
					_on_TodoItems_nothing_selected()
				else:
					StatusLabel.display_status(3, 'Select an item first')
			KEY_E:
				if _current_item >= 0:
					ModifyItem.start_edit(_current_item, TodoItems.get_item_text(_current_item))
					MainTabs.set_deferred('current_tab', 1)
				else:
					StatusLabel.display_status(3, 'Select an item first')

func _on_TodoItems_nothing_selected() -> void:
	_current_item = -1
