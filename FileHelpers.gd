extends Node

func file_exists(path: String) -> bool:
	var dir := Directory.new()
	return dir.file_exists(path)

func read_json_file(path: String):
	if not file_exists(path):
#		push_error("Error: '%s' does not exist" % path)
		return ERR_FILE_NOT_FOUND
	
	var file := File.new()
	var err := file.open(path, File.READ)
	if err:
		push_error("Error: failed to open '%s'." % path)
		return err
	
	# Read text as JSON string
	var data = file.get_as_text()
	data = JSON.parse(data)
	if data.error:
		push_error("Error parsing JSON: %s (around line %d)" % [data.error_string, data.error_line])
		return data.error
	
	return data.result

func write_json_file(path: String, data) -> int:
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
