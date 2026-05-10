extends CanvasLayer

@onready var score_label = $Control/Label

func _ready() -> void:
	score_label.text = "Score: 0"
	Gamemanager.score_changed.connect(update_score)

func update_score(new_score):
	score_label.text = "Score: " + str(new_score)
