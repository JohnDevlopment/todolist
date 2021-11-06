extends Node

func file_exists(path: String) -> bool:
	var dir := Directory.new()
	return dir.file_exists(str('user://', path))

func read_data(path: String):
	if not file_exists(path): return ERR_FILE_NOT_FOUND
	
	path = 'user://' + path
	
	print("read_data: attempt to read ", path)
	
	var file := File.new()
	var err := file.open(path, File.READ)
	if err:
		push_error("Failed to open '%s'." % path)
		return err
	
	# Read text as JSON string
	var data = file.get_as_text()
	data = JSON.parse(data)
	if data.error:
		push_error("Error parsing JSON: %s (around line %d)" % [data.error_string, data.error_line])
		return data.error
	
	return data.result

func save_config(file: ConfigFile, path: String) -> int:
	return file.save('user://' + path)

func write_data(path: String, data) -> int:
	path = str('user://', path)
	
	if not data is Array and not data is Dictionary:
		push_error("Cannot write data to file: must be an array or dictionary.")
		return ERR_INVALID_PARAMETER
	
	var file := File.new()
	var err := file.open(path, File.WRITE)
	if err:
		push_error("Failed to open '%s'." % path)
		return err
	
	data = JSON.print(data)
	file.store_string(data)
	file.close()
	
	return OK
