extends Control


@onready var option_button = $HBoxContainer/OptionButton as OptionButton

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

func _ready():
	add_resolution_items()
	option_button.item_selected.connect(on_resolution_selected)
	

func add_resolution_items() -> void:
	for resolution_size_text in RESOLUTION_DICTIONARY:
		option_button.add_item(resolution_size_text)

func on_resolution_selected(index : int) -> void:
	DisplayServer.window_set_size(RESOLUTION_DICTIONARY.values()[index])
