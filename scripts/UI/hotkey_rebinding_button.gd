class_name HotkeyRebindingButton

extends Control

@onready var label = $HBoxContainer/Label as Label
@onready var button = $HBoxContainer/Button as Button

@export var action_name : String = "move_up"

func _ready():
	set_process_unhandled_key_input(false)
	set_action_name()
	set_text_for_key()
	load_keybinds()


func load_keybinds() -> void:
	rebind_action_key(SettingsDataContainer.get_keybind(action_name))


func set_action_name() -> void:
	label.text = "Не назначено"
	
	match action_name:
		"move_up":
			label.text = "Движение Вверх"
		"move_down":
			label.text = "Движение Вниз"
		"move_left":
			label.text = "Движение Влево"
		"move_right":
			label.text = "Движение Вправо"
		"inventory":
			label.text = "Инвентарь"
		"run":
			label.text = "Бег"
		"attack":
			label.text = "Атаковать"
		"block":
			label.text = "Блокирование"
		"action":
			label.text = "Действие"

func set_text_for_key() -> void:
	var action_events = InputMap.action_get_events(action_name)
	if action_events.size() > 0:
		var action_event = action_events[0]
		var action_keycode = OS.get_keycode_string(action_event.physical_keycode)
		button.text = "%s" % action_keycode
	else:
		button.text = "Нет привязки!"
	


func _on_button_toggled(button_pressed):
	if button_pressed:
		button.text = "Нажмите клавишу"
		set_process_unhandled_key_input(button_pressed)
		
		for i in get_tree().get_nodes_in_group("hotkey_button"):
			if i.action_name != self.action_name:
				i.button.toggle_mode = false
				i.set_process_unhandled_key_input(false)
		
	else:
		
		for i in get_tree().get_nodes_in_group("hotkey_button"):
			if i.action_name != self.action_name:
				i.button.toggle_mode = true
				i.set_process_unhandled_key_input(false)
		
		set_text_for_key()

func _unhandled_key_input(event):
	rebind_action_key(event)
	button.button_pressed = false
	
func rebind_action_key(event) -> void:
	InputMap.action_erase_events(action_name)
	InputMap.action_add_event(action_name, event)
	SettingsDataContainer.set_keybind(action_name, event)
	
	set_process_unhandled_key_input(false)
	set_text_for_key()
	set_action_name()



