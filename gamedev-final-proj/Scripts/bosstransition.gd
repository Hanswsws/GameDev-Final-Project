extends Node

# Nodes
@onready var color_rect = $ColorRect
@onready var animation_player = $AnimationPlayer

# Scene to switch to
var target_scene: PackedScene = null

# Signal to notify when transition starts (optional)
signal on_transition_started
signal on_transition_finished

func _ready():
	color_rect.visible = false
	# Connect animation finished signal
	animation_player.animation_finished.connect(_on_animation_finished)

# This function is called when an animation finishes
func _on_animation_finished(anim_name):
	if anim_name == "fadeblack":
		emit_signal("on_transition_started")
		animation_player.play("fadeout")
		# Change scene immediately after fadeblack
		if target_scene:
			get_tree().change_scene_to_file(target_scene.resource_path)
			target_scene = null
	elif anim_name == "fadeout":
		color_rect.visible = false
		emit_signal("on_transition_finished")

# Call this function to transition to another scene
func transition(scene_path: String):
	target_scene = load(scene_path)
	color_rect.visible = true
	animation_player.play("fadeblack")
