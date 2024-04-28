extends Control


func _on_graphics_pressed():
	get_tree().change_scene_to_file("res://scenes/graphics_menu.tscn")


func _on_audio_pressed():
	get_tree().change_scene_to_file("res://scenes/audio_menu.tscn")


func _on_back_from_options_pressed():
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
