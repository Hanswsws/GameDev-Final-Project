extends CharacterBody2D

@export var speed: float = 400.0
@export var separation_radius: float = 80.0
@export var separation_strength: float = 700.0
@export var damage: int = 10
@export var attack_cooldown: float = 1.0
@export var max_health: int = 30

var can_attack := true
var health: int
var dead = false
var target: Node2D
var player: Node2D
var player_in_range := false

func _ready():
	player = get_tree().get_first_node_in_group("player")
	health = max_health
	$AnimatedSprite2D.play("slime_walk")
	
func _physics_process(delta):
	if player == null or dead:
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
	
	if player_in_range and can_attack:
		attack_player()
	
		
func attack_player():
	can_attack = false

	if player.has_method("take_damage"):
		player.take_damage(damage)

	await get_tree().create_timer(attack_cooldown).timeout

	can_attack = true

func take_damage(amount):

	if dead:
		return

	health -= amount

	print("Enemy health:", health)

	# Play hurt animation
	$AnimatedSprite2D.play("slime_hurt")

	if health <= 0:
		die()

func die():

	dead = true

	velocity = Vector2.ZERO

	# Play death animation
	$AnimatedSprite2D.play("slime_death")

	# Wait for animation to finish
	await $AnimatedSprite2D.animation_finished

	queue_free()
	
func _on_animated_sprite_2d_animation_finished() -> void:
	if dead:
		return

	if $AnimatedSprite2D.animation == "slime_hurt":
		$AnimatedSprite2D.play("slime_walk")


func _on_attackarea_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_range = true
		



func _on_attackarea_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_range = false
