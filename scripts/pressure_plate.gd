extends Area2D

signal activated
signal deactivated

@export var activate_on_enter := true
@export var required_weight := 0

var is_activated := false
var overlapping_bodies := []

func _on_body_entered(body):
	overlapping_bodies.append(body)
	if activate_on_enter and not is_activated and calculate_total_weight() >= required_weight:
		activate()

func _on_body_exited(body):
	overlapping_bodies.erase(body)
	if activate_on_enter and is_activated and calculate_total_weight() < required_weight:
		deactivate()

func activate():
	is_activated = true
	emit_signal("activated")

func deactivate():
	is_activated = false
	emit_signal("deactivated")

func calculate_total_weight():
	var total_weight := 0
	for body in overlapping_bodies:
		if body.has_method("get_weight"):
			total_weight += body.get_weight()
	return total_weight
