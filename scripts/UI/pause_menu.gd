extends Control

#@export var game_manager : GameManager

var selected_buttons_index = 0
var is_keyboard_selected = false

func _ready():
	hide()
	#game_manager.connect("toggle_game_paused", on_game_manager_toggle_game_paused)
	select_button(0)


func _process(delta):
	pass


# Функция для выбора кнопки по индексу
func select_button(index) -> void:
	var buttons = get_tree().get_nodes_in_group("pause_menu_buttons")
	if index >= 0 and index < buttons.size():
		# Снимаем выделение с предыдущей кнопки
		buttons[selected_buttons_index].grab_focus()
		
		# Выбираем новую кнопку
		selected_buttons_index = index
		buttons[selected_buttons_index].grab_focus()
		is_keyboard_selected = true


func _unhandled_input(event):
	if event is InputEventKey and not event.is_echo():
		if Input.is_action_just_pressed("move_up") or Input.is_action_just_pressed("ui_up"):
			select_button((selected_buttons_index - 1) % get_tree().get_nodes_in_group("pause_menu_buttons").size())
		elif Input.is_action_just_pressed("move_down") or Input.is_action_just_pressed("ui_down"):
			select_button((selected_buttons_index + 1) % get_tree().get_nodes_in_group("pause_menu_buttons").size())



func on_game_manager_toggle_game_paused(is_paused : bool):
	if(is_paused):
		show()
	else:
		hide()


func _on_Button_mouse_entered():
	is_keyboard_selected = false

func _on_Button_mouse_exited():
	if is_keyboard_selected:
		select_button(selected_buttons_index)


func _on_resume_button_pressed():
	#game_manager.game_paused = false
	#get_tree().paused = false
	toggle_pause()


func _on_exit_button_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/UI/main_menu.tscn")


func toggle_pause():
	get_tree().paused = !get_tree().paused
	visible = get_tree().paused
