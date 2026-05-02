extends CharacterBody2D

@export var speed = 700

@onready var sprite = $AnimatedSprite2D
@onready var attack_area = $attackarea

#@onready var healthbar = $healthbar

var health = 100
var attacking = false
var hurt = false
var dead = false
var current_damage = 0
var respawn_position = Vector2.ZERO

func _ready():
	attack_area.monitoring = false
	respawn_position = global_position

	attack_area.monitoring = false
	respawn_position = global_position

	#healthbar.max_value = 100
	#healthbar.value = health

func _physics_process(delta:float) -> void:
	if dead or hurt:
		move_and_slide()
		return

	if attacking:
		velocity.x = 0
		move_and_slide()
		return

	var direction = Vector2.ZERO

	if Input.is_action_pressed("left"):
		direction.x -= 1
	if Input.is_action_pressed("right"):
		direction.x += 1
	if Input.is_action_pressed("up"):
		direction.y -= 1
	if Input.is_action_pressed("down"):
		direction.y += 1

	# ✅ ALWAYS update velocity
	direction = direction.normalized()
	
	velocity = direction * speed
	
	if direction != Vector2.ZERO:
		sprite.flip_h = direction.x < 0
		sprite.play("walk")
	else:
		sprite.play("idle")

	# ✅ ALWAYS call movement
	move_and_slide()
# ---------------- ATTACK 1 ----------------
func attack1():

	attacking = true
	# current_damage = attack_damage

	sprite.play("attack1")
	# sfx_attack_1.play()
	attack_area.monitoring = true
	await sprite.animation_finished
	attack_area.monitoring = false

	attacking = false
	
	
	

# ---------------- DAMAGE ENEMY -------------
func _on_attackarea_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemy"):
		body.take_damage(current_damage)
		

# ---------------- PLAYER TAKES DAMAGE ----------------
func take_damage(amount):

	if dead:
		return

	health -= amount

	#healthbar.value = health

	print("Player health:", health)

	hurt = true
	sprite.play("hurt")
	# sfx_damage.play()
	await sprite.animation_finished

	hurt = false

	if health <= 0:
		die()
		

func die():

# ---------------- PLAYER DEATH ----------------
	dead = true
	sprite.play("death")
	# sfx_death.play()
	await sprite.animation_finished

	global_position = respawn_position
	health = 100
	#healthbar.value = health

	dead = false
