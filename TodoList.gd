extends Panel

export var check_color: Color

const INVALID_VALUE: int = 0xffffffff
const CONFIG_FILE := 'todolist.cfg'

var todo_items: ItemList
var resources: ResourcePreloader
var config := {'data_file': 'todo_items.json'}

var _current_item := -1

func _ready() -> void:
	todo_items = $Margin/VBoxContainer/TodoItems
	resources = $ResourcePreloader
	
	# Read config file
	var config_file := ConfigFile.new()
	if UserDataDir.file_exists(CONFIG_FILE):
		# Read config file
		var value = config_file.get_value('', 'data_file', INVALID_VALUE)
		if value != INVALID_VALUE:
			config.data_file = value
	else:
		# Write config file
		save_config(config_file)
	
	# Read list file
	var list_data = UserDataDir.read_data(config.data_file)
	if list_data is Array:
		var i := 0
		for dict in list_data:
			var icon = resources.get_resource('check') if dict.finished else null
			todo_items.add_item(dict.text, icon)
			todo_items.set_item_icon_modulate(i, check_color)
			i += 1
	
	$Margin/VBoxContainer/Menu/File.get_popup().connect('index_pressed', self, '_on_File_menu_index_pressed')

func _exit_tree() -> void:
	var item_list := []
	for i in todo_items.get_item_count():
		var item_text = todo_items.get_item_text(i)
		var icon = todo_items.get_item_icon(i)
		item_list.push_back({
			text = item_text if item_text is String else 'No text available',
			finished = true if icon != null else false
		})
	
	UserDataDir.write_data('todo_items.json', item_list)
	save_config(ConfigFile.new())

func save_config(config_file: ConfigFile):
	config_file.set_value('', 'data_file', config.data_file)
	
	var err := config_file.save('user://' + CONFIG_FILE)
	if err:
		$AcceptDialog.dialog_text = "Failed to open 'user://%s'." % config.data_file
		$AcceptDialog.popup_centered()

func _on_TodoItems_item_activated(index: int) -> void:
	_current_item = index
	
	var icon = todo_items.get_item_icon(_current_item)
	if not icon:
		icon = resources.get_resource('check')
	else:
		icon = null
	
	todo_items.set_item_icon(_current_item, icon)
	todo_items.set_item_icon_modulate(_current_item, check_color)

func _on_TodoItems_item_selected(index: int) -> void:
	_current_item = index

func _on_add_todo_item() -> void:
	var text: String = $Margin/VBoxContainer/AddItem/Name.text
	if not text.empty():
		todo_items.add_item(text)
		$Margin/VBoxContainer/AddItem/Name.text = ''
		todo_items.grab_focus()

func _on_TodoItems_nothing_selected() -> void:
	_current_item = -1

func _on_TodoItems_gui_input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.scancode == KEY_DELETE:
			if _current_item >= 0:
				todo_items.remove_item(_current_item)
				_on_TodoItems_nothing_selected()

func _on_File_menu_index_pressed(index: int) -> void:
	match index:
		0:
			$FileDialog.popup_centered_ratio(0.85)

func _on_FileDialog_file_selected(path: String) -> void:
	config.data_file = path
