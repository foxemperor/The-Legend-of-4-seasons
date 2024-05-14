class_name OptionsMenu
extends Control

@onready var back_button = $MarginContainer/VBoxContainer/Back_btn as Button
@onready var settings_container = $MarginContainer/VBoxContainer/SettingsContainer as SettingsTabContainer

signal exit_options_menu()

func _ready():
	back_button.button_down.connect(_on_exit_pressed)
	settings_container.Exit_Options_menu.connect(_on_exit_pressed)
	set_process(false) # Во избежание проблем с исчезновением меню при большом количестве сцен

func _on_exit_pressed() -> void:
	exit_options_menu.emit()
	SettingsSignalBus.emit_set_settings_dictionary(SettingsDataContainer.create_storage_dictionary())
	set_process(false)
