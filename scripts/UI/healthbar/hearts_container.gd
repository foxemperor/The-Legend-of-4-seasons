extends HBoxContainer

@onready var HeartGUIClass = preload("res://scenes/UI/healthbar/heart_gui.tscn")

var max_health = 0
var full_hearts = []  # Массив для полных сердечек
var empty_hearts = []  # Массив для пустых сердечек

func set_max_hearts(max: int):
	max_health = max
	full_hearts = []  # Очищаем массивы
	empty_hearts = [] 
	for i in range(max):
		var heart = HeartGUIClass.instantiate()
		add_child(heart)
		full_hearts.append(heart)  # Добавляем сердечко в массив полных
	full_hearts = get_children()
	update_hearts(max)

func update_hearts(current_health: int):
	# Обновляем массивы полных и пустых сердечек
	full_hearts = full_hearts.slice(0, current_health)  # Обрезаем массив full_hearts
	empty_hearts = get_children().slice(current_health) # Создаем массив empty_hearts

	# Обновляем отображение сердечек
	for heart in full_hearts:
		heart.update(true)
	for heart in empty_hearts:
		heart.update(false)

# Метод для получения массива полных сердечек
func get_full_hearts():
	return full_hearts.size()
