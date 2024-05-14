class_name Transporter

extends Area2D

@export var destination_level_tag: String
@export var destination_transporter_tag: String
@export var spawn_direction = "up"

@onready var spawn = $Spawn


func _on_body_entered(body):
	if body is Player:
		NavigationManager.go_to_level(destination_level_tag, destination_transporter_tag)
