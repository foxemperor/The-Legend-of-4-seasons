extends HBoxContainer

@onready var HeartGUIClass = preload("res://scenes/UI/healthbar/heart_gui.tscn")

func set_max_hearts(max: int):
	for i in range(max):
		var heart = HeartGUIClass.instantiate()
		add_child(heart)
		
func update_hearts(current_health: int):
	var hearts = get_children()
	
	for i in range(current_health):
		hearts[i].update(true)
		
	for i in range(current_health, hearts.size()):
		hearts[i].update(false)
