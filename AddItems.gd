tool
extends ItemList

export(int, 1, 100) var number_of_items := 0
export var add_items := false setget set_add_items

func set_add_items(v):
	add_items = v
	if add_items:
		add_items()
		call_deferred('set_script', null)

# warning-ignore:function_conflicts_variable
func add_items():
	for i in number_of_items:
		add_item("Item %d" % i)
