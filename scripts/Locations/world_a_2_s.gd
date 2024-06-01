extends Node2D

@onready var hearts_container = $CanvasLayer/HeartsContainer
@onready var player = $TileMap/Player

func _ready():
	hearts_container.set_max_hearts(player.max_health)
	hearts_container.update_hearts(player.current_health)
	player.health_changed.connect(hearts_container.update_hearts)
	
	if NavigationManager.spawn_transporter_tag != null:
		_on_level_spawn(NavigationManager.spawn_transporter_tag)

func _on_level_spawn(destination_tag: String):
	var teleport_path = "Teleports/Transporter_" + destination_tag
	var teleport = get_node(teleport_path) as Transporter
	NavigationManager.trigger_player_spawn(teleport.spawn.global_position, teleport.spawn_direction)
	
