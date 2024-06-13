extends Node2D

signal interacted

@export var is_interactive := true

func interact():
	if is_interactive:
		emit_signal("interacted")
