extends Node


@onready var DEFAULT_SETTINGS : DefaultSettingsResources = preload("res://resources/settings/default_settings.tres")
@onready var keybind_resource : PlayerKeybindResource = preload("res://resources/settings/default_keybind.tres")

# Переменные для создания Менеджера Настроек игры
var window_mode_index : int = 0
var resolution_index : int = 0
var master_volume : float = 0.0
var music_volume : float = 0.0
var sfx_volume : float = 0.0

var loaded_data : Dictionary = {} # Избыточная переменная

func _ready():
	handle_signals()
	create_storage_dictionary()

func create_storage_dictionary() -> Dictionary:
	var settings_container_dict : Dictionary = {
		"window_mode_index" : window_mode_index,
		"resolution_index" : resolution_index,
		"master_volume" : master_volume,
		"music_volume" : music_volume,
		"sfx_volume" : sfx_volume,
		"keybinds" : create_keybinds_dictionary()
	}
	
	return settings_container_dict


func create_keybinds_dictionary() -> Dictionary:
	var keybinds_container_dict = {
		keybind_resource.MOVE_UP : keybind_resource.move_up_key,
		keybind_resource.MOVE_DOWN : keybind_resource.move_down_key,
		keybind_resource.MOVE_LEFT : keybind_resource.move_left_key,
		keybind_resource.MOVE_RIGHT : keybind_resource.move_right_key,
		keybind_resource.INVENTORY : keybind_resource.inventory_key,
		keybind_resource.RUN : keybind_resource.run_key,
		keybind_resource.ATTACK : keybind_resource.attack_key,
		keybind_resource.BLOCK : keybind_resource.block_key,
		keybind_resource.ACTION : keybind_resource.action_key
	}
	
	return keybinds_container_dict


# Функции доступа
func get_window_mode_index() -> int:
	if loaded_data == {}:
		return DEFAULT_SETTINGS.DEFAULT_WINDOW_MODE_INDEX
	return window_mode_index


func get_resolution_index() -> int:
	if loaded_data == {}:
		return DEFAULT_SETTINGS.DEFAULT_RESOLUTION_INDEX
	return resolution_index


func get_master_volume() -> float:
	if loaded_data == {}:
		return DEFAULT_SETTINGS.DEFAULT_MASTER_VOLUME
	return master_volume

func get_music_volume() -> float:
	if loaded_data == {}:
		return DEFAULT_SETTINGS.DEFAULT_MUSIC_VOLUME
	return music_volume

func get_sfx_volume() -> float:
	if loaded_data == {}:
		return DEFAULT_SETTINGS.DEFAULT_SFX_VOLUME
	return sfx_volume

# Функции реализующие Менеджер Настроек игры

func on_window_mode_selected(index : int) -> void:
	window_mode_index = index


func on_resolution_selected(index : int) -> void:
	resolution_index = index


func on_master_sound_set(value : float) -> void:
	master_volume = value


func on_music_sound_set(value : float) -> void:
	music_volume = value


func on_sfx_sound_set(value : float) -> void:
	sfx_volume = value


func get_keybind(action : String):
	if !loaded_data.has("keybinds"):
		match action:
			keybind_resource.MOVE_UP:
				return keybind_resource.DEFAULT_MOVE_UP_KEY
			keybind_resource.MOVE_DOWN:
				return keybind_resource.DEFAULT_MOVE_DOWN_KEY
			keybind_resource.MOVE_LEFT:
				return keybind_resource.DEFAULT_MOVE_LEFT_KEY
			keybind_resource.MOVE_RIGHT:
				return keybind_resource.DEFAULT_MOVE_RIGHT_KEY
			keybind_resource.INVENTORY:
				return keybind_resource.DEFAULT_INVENTORY_KEY
			keybind_resource.RUN:
				return keybind_resource.DEFAULT_RUN_KEY
			keybind_resource.ATTACK:
				return keybind_resource.DEFAULT_ATTACK_KEY
			keybind_resource.BLOCK:
				return keybind_resource.DEFAULT_BLOCK_KEY
			keybind_resource.ACTION:
				return keybind_resource.DEFAULT_ACTION_KEY
		print("Раскладка по-умолчанию")
	else:
		match action:
			keybind_resource.MOVE_UP:
				return keybind_resource.move_up_key
			keybind_resource.MOVE_DOWN:
				return keybind_resource.move_down_key
			keybind_resource.MOVE_LEFT:
				return keybind_resource.move_left_key
			keybind_resource.MOVE_RIGHT:
				return keybind_resource.move_right_key
			keybind_resource.INVENTORY:
				return keybind_resource.inventory_key
			keybind_resource.RUN:
				return keybind_resource.run_key
			keybind_resource.ATTACK:
				return keybind_resource.attack_key
			keybind_resource.BLOCK:
				return keybind_resource.block_key
			keybind_resource.ACTION:
				return keybind_resource.action_key
		print("Пользовательская раскладка")
	


func set_keybind(action : String, event) -> void:
	match action:
		keybind_resource.MOVE_UP:
			keybind_resource.move_up_key = event
		keybind_resource.MOVE_DOWN:
			keybind_resource.move_down_key = event
		keybind_resource.MOVE_LEFT:
			keybind_resource.move_left_key = event
		keybind_resource.MOVE_RIGHT:
			keybind_resource.move_right_key = event
		keybind_resource.INVENTORY:
			keybind_resource.inventory_key = event
		keybind_resource.RUN:
			keybind_resource.run_key = event
		keybind_resource.ATTACK:
			keybind_resource.attack_key = event
		keybind_resource.BLOCK:
			keybind_resource.block_key = event
		keybind_resource.ACTION:
			keybind_resource.action_key = event


func on_keybinds_loaded(data : Dictionary) -> void:
	var loaded_move_up = InputEventKey.new()
	var loaded_move_down = InputEventKey.new()
	var loaded_move_left = InputEventKey.new()
	var loaded_move_right = InputEventKey.new()
	var loaded_inventory = InputEventKey.new()
	var loaded_run = InputEventKey.new()
	var loaded_attack = InputEventKey.new()
	var loaded_block = InputEventKey.new()
	var loaded_action = InputEventKey.new()
	
	loaded_move_up.set_physical_keycode(int(data.move_up))
	loaded_move_down.set_physical_keycode(int(data.move_down))
	loaded_move_left.set_physical_keycode(int(data.move_left))
	loaded_move_right.set_physical_keycode(int(data.move_right))
	loaded_inventory.set_physical_keycode(int(data.inventory))
	loaded_run.set_physical_keycode(int(data.run))
	loaded_attack.set_physical_keycode(int(data.attack))
	loaded_block.set_physical_keycode(int(data.block))
	loaded_action.set_physical_keycode(int(data.action))
	
	keybind_resource.move_up_key = loaded_move_up
	keybind_resource.move_down_key = loaded_move_down
	keybind_resource.move_left_key = loaded_move_left
	keybind_resource.move_right_key = loaded_move_right
	keybind_resource.inventory_key = loaded_inventory
	keybind_resource.run_key = loaded_run
	keybind_resource.attack_key = loaded_attack
	keybind_resource.block_key = loaded_block
	keybind_resource.action_key = loaded_action


func on_settings_data_loaded(data : Dictionary) -> void:
	loaded_data = data
	on_window_mode_selected(loaded_data.window_mode_index)
	on_resolution_selected(loaded_data.resolution_index)
	on_master_sound_set(loaded_data.master_volume)
	on_music_sound_set(loaded_data.music_volume)
	on_sfx_sound_set(loaded_data.sfx_volume)
	on_keybinds_loaded(loaded_data.keybinds)


func handle_signals() -> void:
	SettingsSignalBus.on_window_mode_selected.connect(on_window_mode_selected)
	SettingsSignalBus.on_resolution_selected.connect(on_resolution_selected)
	SettingsSignalBus.on_master_sound_set.connect(on_master_sound_set)
	SettingsSignalBus.on_music_sound_set.connect(on_music_sound_set)
	SettingsSignalBus.on_sfx_sound_set.connect(on_sfx_sound_set)
	SettingsSignalBus.load_settings_data.connect(on_settings_data_loaded)
