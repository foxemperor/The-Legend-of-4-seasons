extends Node

const scene_level1 = preload("res://scenes/Locations/world_a_1_s.tscn")
const scene_level2 = preload("res://scenes/Locations/world_a_2_s.tscn")

var spawn_transporter_tag

signal on_trigger_player_spawn
signal level_loaded(destination_tag)

func go_to_level(level_tag: String, destination_tag: String):
	var scene_to_load = get_level_scene(level_tag)
	
	if scene_to_load != null:
		spawn_transporter_tag = destination_tag
		call_deferred("change_scene", scene_to_load)
	else:
		push_error("Level scene not found for level_tag: " + level_tag)


func change_scene(scene_to_load):
	get_tree().change_scene_to_packed(scene_to_load)
	call_deferred("connect_and_emit", spawn_transporter_tag)
	


func connect_and_emit():
	# Подключаем сигнал после загрузки сцены
	var player = get_tree().current_scene.find_node("Player") # Находим игрока в сцене
	if player:
		player.connect("level_loaded", player, "_on_level_loaded")
	level_loaded.emit(spawn_transporter_tag) # Эмитируем сигнал после загрузки сцены


func get_level_scene(level_tag: String) -> PackedScene:
	match level_tag:
		"world_A1":
			return scene_level1
		"world_A2":
			return scene_level2
		
		_:
			return null


func trigger_player_spawn(position: Vector2i, direction: String):
	on_trigger_player_spawn.emit(position, direction)
