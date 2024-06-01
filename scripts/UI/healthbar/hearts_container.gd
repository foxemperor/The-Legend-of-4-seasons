extends HBoxContainer

@onready var HeartGUIClass = preload("res://scenes/UI/healthbar/heart_gui.tscn")

var max_health = 0  # Объявляем переменную max_health

func set_max_hearts(max: int):
	max_health = max 
	for i in range(max):
		var heart = HeartGUIClass.instantiate()
		add_child(heart)
	update_hearts(max)  # Вызываем update_hearts после создания сердечек

func update_hearts(current_health: int):
	var hearts = get_children()
	
	for i in range(current_health):
		hearts[i].update(true)
		
	for i in range(current_health, hearts.size()):
		hearts[i].update(false)
