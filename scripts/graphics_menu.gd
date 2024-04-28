extends Control

@onready var display_mode = $PanelContainer/MarginContainer/HBoxContainer/Checks/DisplayMode
@onready var resolution = $PanelContainer/MarginContainer/HBoxContainer/Checks/Resolution


# Массив настроек выбора режима отображения окна
const WINDOW_MODE_ARRAY : Array[String] = [
	"FullScreen",
	"Borderless",
	"Windowed"
]

# Готовимся к переключению окна в другой режим работы
func _ready():
	add_window_mode_items()
	display_mode.item_selected.connect(_on_window_mode_selected)
	
	add_resolution_items()
	resolution.item_selected.connect(_on_resolution_selected)

# Добавляем режимы работы окна в OptionButton
func add_window_mode_items() -> void:
	for window_mode in WINDOW_MODE_ARRAY:
		display_mode.add_item(window_mode)

# Выбор режима работы окна приложения
func _on_window_mode_selected(index : int) -> void:
	match index:
		0: # FullScreen
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
		1: # Borderless window
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)
		2: # Windowed
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)

# Словарь соответсвий форматов разрешения к вестору 2i
const RESOLUTION_DICTIONARY : Dictionary = {
	"800x600" : Vector2i(800, 600),
	"1024x768" : Vector2i(1024, 768),
	"1152x864" : Vector2i(1152, 864),
	"1280x720" : Vector2i(1280, 720),
	"1280x768" : Vector2i(1280, 768),
	"1280x800" : Vector2i(1280, 800),
	"1280x960" : Vector2i(1280, 960),
	"1280x1024" : Vector2i(1280, 1024),
	"1360x768" : Vector2i(1360, 768),
	"1366x768" : Vector2i(1366, 768),
	"1400x1050" : Vector2i(1400, 1050),
	"1440x900" : Vector2i(1440, 900),
	"1600x900" : Vector2i(1600, 900),
	"1680x1050" : Vector2i(1680, 1050),
	"1920x1080" : Vector2i(1920, 1080),
	"2560x1440" : Vector2i(2560, 1440),
	"3840x2160" : Vector2i(3840, 2160)
}

# Функция преобразующая значения словаря в элемент OptionButton
func add_resolution_items() -> void:
	for resolution_size_text in RESOLUTION_DICTIONARY:
		resolution.add_item(resolution_size_text)

# Функция применяющая выбраное разрешение
func _on_resolution_selected(index : int) -> void:
	DisplayServer.window_set_size(RESOLUTION_DICTIONARY.values()[index])

# Включение Вертикальной Синхронизации
func _on_v_sync_toggled(_toggled_on):
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)

# Возврат к вкладке Опции
func _on_back_from_graphics_pressed():
	get_tree().change_scene_to_file("res://scenes/options_menu.tscn")

