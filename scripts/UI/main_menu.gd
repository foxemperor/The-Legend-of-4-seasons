class_name MainMenu
extends Control

@onready var start_btn = $Menu/VBoxContainer/New as Button
@onready var load_btn = $Menu/VBoxContainer/Load as Button
@onready var exit_btn = $Menu/VBoxContainer/Exit as Button
@onready var options_btn = $Menu/VBoxContainer/Options as Button

@onready var logo_container = $Logo
@onready var menu_container = $Menu
@onready var options_menu = $Options_menu as OptionsMenu

# Флаг для скрытия главного меню и видимости настроек
var is_option_menu_visible = false


func _process(_delta):
	# Условия для флага
	logo_container.visible = !is_option_menu_visible
	menu_container.visible = !is_option_menu_visible
	options_menu.visible = is_option_menu_visible
	
	# Вызвать функцию если нажата клавиша ESC
	if Input.is_action_just_pressed("ui_cancel"):
		toggle()

func toggle():
	visible = !visible
	get_tree().paused = visible

# При нажатии на кнопку Новая игра
func _on_new_pressed() -> void:
	toggle()
	get_tree().change_scene_to_file("res://scenes/test_scene.tscn")

func _on_load_pressed() -> void:
	pass 

# При нажатии на кнопку Настройки
func _on_options_pressed() -> void:
	is_option_menu_visible = true
	options_menu.set_process(true)

# При нажатии на кнопку Авторы
func _on_credits_pressed() -> void:
	pass

# При нажатии на кнопку Выход
func _on_exit_pressed() -> void:
	get_tree().quit()


func handle_connecting_signals() -> void:
	start_btn.button_down.connect(_on_new_pressed)
	options_btn.button_down.connect(_on_options_pressed)
	exit_btn.button_down.connect(_on_exit_pressed)


func _on_options_menu_exit_options_menu():
	is_option_menu_visible = false
