extends InteractiveObject

signal toggled

@export var is_on := false

func interact():
	interact()
	is_on = not is_on
	emit_signal("toggled", is_on)
