extends CanvasLayer

@onready var color_rect = $ColorRect
@onready var label      = $ColorRect/Label

signal transition_finished

func transition_to(scene_path: String, level_label: String = ""):
	if level_label != "":
		label.text = level_label
		label.visible = true
	else:
		label.visible = false

	var tween = create_tween()
	tween.tween_property(color_rect, "modulate:a", 1.0, 0.6)
	await tween.finished

	await get_tree().create_timer(0.8).timeout
	get_tree().change_scene_to_file(scene_path)
