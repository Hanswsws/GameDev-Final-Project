extends CharacterBody2D

signal boss_died

@export var speed: float = 400.0
@export var damage: int = 25
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
	add_to_group("enemies")

	if $bosshealth:
		$bosshealth.max_value = max_health
		$bosshealth.value = health

func _physics_process(delta):
	if player == null or dead:
		return

	var direction = (player.global_position - global_position).normalized()

	if is_attacking:
		velocity = Vector2.ZERO
	else:
		velocity = direction * speed

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
	$AnimatedSprite2D.play("robotboss_attack")
	await get_tree().create_timer(0.3).timeout
	if player and player.has_method("take_damage"):
		player.take_damage(damage)
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
	$AnimatedSprite2D.play("robotboss_hurt")
	if health <= 0:
		die()

func die():
	dead = true
	velocity = Vector2.ZERO

	if $bosshealth:
		$bosshealth.visible = false

	$AnimatedSprite2D.play("robotboss_death")
	await $AnimatedSprite2D.animation_finished

	Gamemanager.add_score(100)

	# Signal that the boss is dead BEFORE removing from scene
	boss_died.emit()

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
