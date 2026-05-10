extends CharacterBody2D

@export var weapons : Array[PackedScene]
@export var speed = 700
@onready var weapon_holder = $weaponholder
@onready var sprite = $AnimatedSprite2D
@onready var attack_area = $attackarea

var health = 100
var attacking = false
var hurt = false
var dead = false
var current_damage = 0
var respawn_position = Vector2.ZERO
var current_weapon : Node
var last_weapon = -1

func _ready():
	attack_area.monitoring = false
	respawn_position = global_position
	randomize()
	swap_weapon()
	
func swap_weapon():

	# remove old weapon
	if current_weapon:
		current_weapon.free()

	# random weapon
	var random_index = randi() % weapons.size()

	# stop repeats
	while random_index == last_weapon and weapons.size() > 1:
		random_index = randi() % weapons.size()

	last_weapon = random_index

	# spawn weapon
	current_weapon = weapons[random_index].instantiate()

	weapon_holder.add_child(current_weapon)

	current_weapon.position = Vector2.ZERO

func _physics_process(delta:float) -> void:
	var mouse_pos = get_global_mouse_position()

	if mouse_pos.x < global_position.x:
		sprite.flip_h = true
	else:
		sprite.flip_h = false
		
	if dead or hurt:
		move_and_slide()
		return

	if attacking:
		velocity.x = 0
		move_and_slide()
		return

	var direction = Vector2.ZERO

	direction.x = Input.get_action_strength("right") - Input.get_action_strength("left")
	direction.y = Input.get_action_strength("down") - Input.get_action_strength("up")

	direction = direction.normalized()

	velocity = direction * speed

	if direction != Vector2.ZERO:
		sprite.play("walk")
	else:
		sprite.play("idle")

	move_and_slide()

# ---------------- ATTACK 1 ----------------
func atk():
	attacking = true
	sprite.play("attack1")
	attack_area.monitoring = true
	await sprite.animation_finished
	attack_area.monitoring = false
	attacking = false

# ---------------- DAMAGE ENEMY ----------------
func _on_attackarea_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemies"):
		body.take_damage(current_damage)

# ---------------- PLAYER TAKES DAMAGE ----------------
func take_damage(amount):
	if dead:
		return

	health -= amount
	print("Player health:", health)

	hurt = true
	sprite.play("hurt")
	await sprite.animation_finished
	hurt = false

	if health <= 0:
		die()

# ---------------- PLAYER DEATH ----------------
func die():
	dead = true
	sprite.play("death")
	await sprite.animation_finished

	# ——— Show the death overlay via the HUD ———
	# get_tree().get_first_node_in_group finds the HUD node in the scene
	var hud = get_tree().get_first_node_in_group("hud")
	if hud:
		hud.show_death_screen()
	else:
		# Fallback if HUD isn't found: just reload the scene
		get_tree().reload_current_scene()


func _on_weaponholderswap_timeout() -> void:
	swap_weapon()
