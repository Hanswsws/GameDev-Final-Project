extends CharacterBody2D

@export var speed: float = 400.0
@export var damage: int = 20
@export var attack_cooldown: float = 1.0
@export var max_health: int = 3000
@onready var healthbar = $bosshealth

var can_attack := true
var health: int
var dead = false
var target: Node2D
var player: Node2D
var player_in_range := false
var is_attacking := false

func _ready():
	player = get_tree().get_first_node_in_group("player")
	health = max_health
	$AnimatedSprite2D.play("robotboss_walk")
	
	if$bosshealth:
		$bosshealth.max_value = max_health
		$bosshealth.value = health
	
func _physics_process(delta):

	if player == null or dead:
		return

	# Direction toward player
	var direction = (player.global_position - global_position).normalized()

	# Stop movement while attacking
	if is_attacking:
		velocity = Vector2.ZERO
	else:
		velocity = direction * speed

	# Flip sprite
	if velocity.x > 0:
		$AnimatedSprite2D.flip_h = true
	elif velocity.x < 0:
		$AnimatedSprite2D.flip_h = false

	move_and_slide()

	if player_in_range and can_attack and not is_attacking:
		attack_player()
		
func attack_player():

	can_attack = false
	is_attacking = true

	velocity = Vector2.ZERO

	# Play attack animation
	$AnimatedSprite2D.play("robotboss_attack")

	# Wait for hit frame
	await get_tree().create_timer(0.3).timeout

	if player.has_method("take_damage"):
		player.take_damage(damage)

	# Wait for animation/cooldown
	await get_tree().create_timer(attack_cooldown).timeout

	is_attacking = false

	if not dead:
		$AnimatedSprite2D.play("robotboss_walk")

	can_attack = true

func take_damage(amount):

	if dead:
		return

	health -= amount

	print("Enemy health:", health)
	healthbar.value = health

	# Play hurt animation
	$AnimatedSprite2D.play("robotboss_hurt")

	if health <= 0:
		die()

func die():

	dead = true

	velocity = Vector2.ZERO
	
	if $bosshealth:
		$bosshealth.visible = false

	# Play death animation
	$AnimatedSprite2D.play("robotboss_death")

	# Wait for animation to finish
	await $AnimatedSprite2D.animation_finished
	Gamemanager.add_score(100)

	queue_free()
	
func _on_animated_sprite_2d_animation_finished() -> void:
	if dead:
		return

	if $AnimatedSprite2D.animation == "robotboss_hurt":
		$AnimatedSprite2D.play("robotboss_walk")


func _on_robotattackarea_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_range = true

func _on_robotattackarea_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_range = false
