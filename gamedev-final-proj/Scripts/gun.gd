extends Node2D

const BULLET = preload("res://Scenes/bullet.tscn")

@onready var muzzle: Marker2D = $Marker2D
@onready var flash = $flash
@onready var flash_timer = $flash/flashTimer

var fire_rate = 0.15
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
		fire_bullet()
		fire_timer = fire_rate

func fire_bullet():
	var bullet_instance = BULLET.instantiate()
	get_tree().root.add_child(bullet_instance)

	bullet_instance.global_position = muzzle.global_position
	bullet_instance.rotation = rotation

	flash.visible = true
	flash_timer.start()

func _on_flash_timer_timeout():
	flash.visible = false
