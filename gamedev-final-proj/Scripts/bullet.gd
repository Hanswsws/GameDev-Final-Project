extends Area2D

const speed: int = 2000
@export var damage: int = 25

func _process(delta: float) -> void:
	position += transform.x * speed * delta

func _on_body_entered(body: Node2D) -> void:
	
	if body.has_method("take_damage"):
		body.take_damage(damage)

	queue_free()

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
