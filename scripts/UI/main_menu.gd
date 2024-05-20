class_name MainMenu
extends Control


@onready var start_btn = $Panel/Menu/VBoxContainer/New as Button
@onready var load_btn = $Panel/Menu/VBoxContainer/Load as Button
@onready var exit_btn = $Panel/Menu/VBoxContainer/Exit as Button
@onready var options_btn = $Panel/Menu/VBoxContainer/Options as Button

@onready var logo_container = $Panel/Logo
@onready var menu_container = $Panel/Menu
@onready var options_menu = $Panel/Options_menu as OptionsMenu

# Флаг для скрытия главного меню и видимости настроек
var is_option_menu_visible = false
# Индекс выбранной кнопки
var selected_buttons_index = 0
# Флаг указывающий, что кнопка выделена с клавиатуры
var is_keyboard_selected = false


# Функция для выбора кнопки по индексу
func select_button(index) -> void:
	var buttons = get_tree().get_nodes_in_group("main_menu_buttons")
	if index >= 0 and index < buttons.size():
		# Снимаем выделение с предыдущей кнопки
		buttons[selected_buttons_index].grab_focus()
		
		# Выбираем новую кнопку
		selected_buttons_index = index
		buttons[selected_buttons_index].grab_focus()
		is_keyboard_selected = true


func _unhandled_input(event):
	if event is InputEventKey and not event.is_echo() and not is_option_menu_visible:
		if Input.is_action_just_pressed("move_up") or Input.is_action_just_pressed("ui_up"):
			select_button((selected_buttons_index - 1) % get_tree().get_nodes_in_group("main_menu_buttons").size())
		elif Input.is_action_just_pressed("move_down") or Input.is_action_just_pressed("ui_down"):
			select_button((selected_buttons_index + 1) % get_tree().get_nodes_in_group("main_menu_buttons").size())


func _ready():
	# При запуске подсвечиваем первую кнопку меню
	select_button(0)


func _process(_delta):
	# Условия для флага
	logo_container.visible = !is_option_menu_visible
	menu_container.visible = !is_option_menu_visible
	options_menu.visible = is_option_menu_visible


func toggle():
	visible = !visible
	get_tree().paused = visible


# При нажатии на кнопку Новая игра
func _on_new_pressed() -> void:
	toggle()
	get_tree().change_scene_to_file("res://scenes/Locations/world_a_1_s.tscn")


# При нажатии на кнопку Продолжить
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


func _on_button_mouse_entered():
	is_keyboard_selected = false


func _on_button_mouse_exited():
	if is_keyboard_selected:
		select_button(selected_buttons_index)
