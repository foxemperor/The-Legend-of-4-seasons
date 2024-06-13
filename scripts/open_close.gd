extends InteractiveObject

@export var is_open := false

func interact():
	interact()
	if is_open:
		close()
	else:
		open()

func open():
	is_open = true
	# Анимация открытия

func close():
	is_open = false
	# Анимация закрытия
