extends Node2D

const BAR_WIDTH  = 50.0
const BAR_HEIGHT = 6.0
const OFFSET     = Vector2(-25, -55)

const COLOR_HIGH = Color(0.15, 0.85, 0.20, 1.0)
const COLOR_MED  = Color(0.95, 0.55, 0.10, 1.0)
const COLOR_LOW  = Color(0.90, 0.12, 0.10, 1.0)
const COLOR_BG   = Color(0.1, 0.08, 0.08, 0.85)

var current_hp : float = 100.0
var max_hp     : float = 100.0
var display_hp : float = 100.0
var player_ref = null

var bg_line   : Line2D
var fill_line : Line2D

func _ready():
	position = OFFSET
	player_ref = get_parent()

	if player_ref and "health" in player_ref:
		current_hp = float(player_ref.health)
		display_hp = current_hp
	if player_ref and "max_health" in player_ref:
		max_hp = float(player_ref.max_health)

	if player_ref and player_ref.has_signal("health_changed"):
		player_ref.health_changed.connect(_on_health_changed)

	_create_bar()

func _create_bar():
	bg_line = Line2D.new()
	bg_line.width = BAR_HEIGHT
	bg_line.default_color = COLOR_BG
	bg_line.add_point(Vector2(0, 0))
	bg_line.add_point(Vector2(BAR_WIDTH, 0))
	add_child(bg_line)

	fill_line = Line2D.new()
	fill_line.width = BAR_HEIGHT
	fill_line.default_color = COLOR_HIGH
	fill_line.add_point(Vector2(0, 0))
	fill_line.add_point(Vector2(BAR_WIDTH, 0))
	add_child(fill_line)

func _on_health_changed(hp: float, mhp: float):
	current_hp = hp
	max_hp = mhp

func _process(delta):
	if player_ref and "health" in player_ref:
		current_hp = float(player_ref.health)
	if player_ref and "max_health" in player_ref:
		max_hp = float(player_ref.max_health)

	display_hp = lerp(display_hp, current_hp, delta * 8.0)
	_update_bar()

func _update_bar():
	if fill_line == null or max_hp <= 0:
		return

	var pct = clamp(display_hp / max_hp, 0.0, 1.0)

	if fill_line.get_point_count() >= 2:
		fill_line.set_point_position(1, Vector2(BAR_WIDTH * pct, 0))

	if pct > 0.70:
		fill_line.default_color = COLOR_HIGH
	elif pct > 0.30:
		fill_line.default_color = COLOR_MED
	else:
		fill_line.default_color = COLOR_LOW
