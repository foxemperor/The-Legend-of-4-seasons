extends Control

@onready var back_button = $Panel/Button as Button
var main_menu : Node # Ссылка на главное меню

# Called when the node enters the scene tree for the first time.
func _ready():
	back_button.button_down.connect(_on_button_pressed)


func _on_button_pressed():
	# Скрываем меню авторов
	visible = false 
	# Показывать главное меню
	main_menu.get_node("Panel/Menu").visible = true
	# Включить обработку событий для главного меню
	main_menu.set_process(true)
