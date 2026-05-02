extends CharacterBody2D

@export var speed: float = 500.0
@export var separation_radius: float = 40.0
@export var separation_strength: float = 300.0
var target: Node2D

var player: Node2D

func _ready():
	player = get_tree().get_first_node_in_group("player")

func _physics_process(delta):
	if player == null:
		return

	# Direction toward player
	var direction = (player.global_position - global_position).normalized()

	# Separation force
	var separation = Vector2.ZERO

	for enemy in get_tree().get_nodes_in_group("enemies"):
		if enemy == self:
			continue

		var dist = global_position.distance_to(enemy.global_position)

		if dist < separation_radius and dist > 0:
			var push = (global_position - enemy.global_position).normalized()
			separation += push / dist  # stronger when closer

	separation *= separation_strength

	# Combine movement
	velocity = (direction * speed) + separation

# Flip here
	if velocity.x < 0:
		$AnimatedSprite2D.flip_h = true
	elif velocity.x > 0:
		$AnimatedSprite2D.flip_h = false

	move_and_slide()
