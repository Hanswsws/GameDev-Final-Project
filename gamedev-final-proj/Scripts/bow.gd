extends Node2D

const ARROW = preload("res://Scenes/arrow.tscn")

@onready var tip: Marker2D = $bowmarker
@onready var sprite = $AnimatedSprite2D

# Base fire rate
var base_fire_rate = 1.0

var fire_rate = 1.0
var fire_timer = 0.0

func _ready() -> void:
	pass

func _process(delta: float) -> void:

	look_at(get_global_mouse_position())


	fire_timer -= delta

	rotation_degrees = wrap(rotation_degrees, 0, 360)

	if rotation_degrees > 90 and rotation_degrees < 270:
		scale.y = -1
	else:
		scale.y = 1

	if Input.is_action_pressed("atk") and fire_timer <= 0:

		fire_arrow()

		fire_timer = fire_rate

func fire_arrow():

	sprite.play("bowshoot")
	
	var arrow_instance = ARROW.instantiate()

	get_tree().root.add_child(arrow_instance)

	arrow_instance.global_position = tip.global_position

	arrow_instance.rotation = rotation

	arrow_instance.shooter = get_parent()

	var bow_sound = $AudioStreamPlayer2D
	if bow_sound:
		bow_sound.play()

	await get_tree().create_timer(1.0).timeout
	
