extends Node2D

@export var damage := 40
@export var attack_distance := 60

# Base cooldown

var attack_cooldown := 0.4

@onready var sprite = $AnimatedSprite2D

var player
var can_attack = true

func _ready():

	player = get_parent().get_parent()
	position = Vector2(attack_distance, 0)
func _process(delta):
	if player == null:
		return
	

	look_at(get_global_mouse_position())

	var mouse_pos = get_global_mouse_position()

	if mouse_pos.x < player.global_position.x:
		scale.y = -1
	else:
		scale.y = 1

	if Input.is_action_just_pressed("atk") and can_attack:

		attack()

func attack():
	can_attack = false
	player.attacking = true
	player.current_damage = damage
	player.attack_area.monitoring = true

	sprite.play("swordswing")

	# Play the sword swing sound
	var sword_sound = $AudioStreamPlayer2D
	if sword_sound:
		sword_sound.play()

	# Wait animation duration
	await get_tree().create_timer(0.3).timeout  # adjust 0.3 to your animation length

	player.attack_area.monitoring = false
	player.attacking = false

	await get_tree().create_timer(attack_cooldown).timeout
	can_attack = true
