tool
extends ItemList

export var clear_items := false setget set_clear_items

func set_clear_items(v):
	clear_items = v
	if clear_items:
		clear()
		call_deferred('set_script', null)

