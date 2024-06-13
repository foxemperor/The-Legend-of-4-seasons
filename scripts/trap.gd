extends Area2D

signal triggered

@export var damage := 10
@export var spike_up_time := 1 # Время подъема кольев
@export var spike_down_time := 0.5 # Время опускания кольев
var is_player_touching := false

@onready var spike_sprite = $SpikeSprite # Ссылка на AnimatedSprite2D

var is_triggered := false

func _process(delta):
	if is_triggered:
		if spike_sprite.animation != "Up": # Если колья не подняты
			spike_sprite.play("Up") 
		else:
			$Timer.start(spike_down_time) # Запускаем таймер опускания
			is_triggered = false
	else:
		if spike_sprite.animation != "Down": # Если колья не опущены
			spike_sprite.play("Down")
	if get_overlapping_bodies().size() > 0:
			for body in get_overlapping_bodies():
				if body.is_in_group("player"):
					trigger()
					break
	if is_player_touching and spike_sprite.animation == "Up":
		for body in get_overlapping_bodies():
			if body.is_in_group("player"):
				var impulse_direction = (body.global_position - global_position).normalized()
				body.velocity = impulse_direction * 20 # Настройте силу отталкивания
				break

func trigger():
	if not is_triggered:
		is_triggered = true
		emit_signal("triggered")

func _on_body_entered(body):
	if body.is_in_group("player"):
		trigger()
		is_player_touching = true

func _on_timer_timeout():
	is_triggered = false

func _on_body_exited(body):
	if body.is_in_group("player"):
		is_player_touching = false
