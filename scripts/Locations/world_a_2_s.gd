extends Node2D


func _ready():
	if NavigationManager.spawn_transporter_tag != null:
		_on_level_spawn(NavigationManager.spawn_transporter_tag)

func _on_level_spawn(destination_tag: String):
	var teleport_path = "Teleports/Transporter_" + destination_tag
	var teleport = get_node(teleport_path) as Transporter
	NavigationManager.trigger_player_spawn(teleport.spawn.global_position, teleport.spawn_direction)
	
