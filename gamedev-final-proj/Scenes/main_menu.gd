extends Control

# ——— Node references ———
@onready var play_button       = $Layout/RightPanel/ButtonsContainer/PlayButton
@onready var credits_button    = $Layout/RightPanel/ButtonsContainer/CreditsButton
@onready var exit_button       = $Layout/RightPanel/ButtonsContainer/ExitButton
@onready var credits_overlay   = $CreditsOverlay
@onready var close_credits_btn = $CreditsOverlay/Panel/VBox/CloseCreditsButton
@onready var dungeon_tiles     = $DungeonTiles
@onready var embers            = $Embers
@onready var player_showcase   = $PlayerShowcase
@onready var title_label       = $Layout/RightPanel/TitleContainer/TitleLabel

# Tile colors sampled from your dungeon floor sprite
const TILE_COLORS = [
	Color(0.18, 0.17, 0.16, 1),
	Color(0.15, 0.14, 0.13, 1),
	Color(0.20, 0.19, 0.18, 1),
	Color(0.13, 0.12, 0.11, 1),
	Color(0.22, 0.20, 0.19, 1),
]

var title_pulse_time = 0.0

func _ready():
	play_button.pressed.connect(_on_play_pressed)
	credits_button.pressed.connect(_on_credits_pressed)
	exit_button.pressed.connect(_on_exit_pressed)
	close_credits_btn.pressed.connect(_on_close_credits_pressed)
	credits_overlay.visible = false

	_build_dungeon_background()
	_setup_embers()
	_setup_player_sprite()

# ——— DUNGEON TILE BACKGROUND ———
func _build_dungeon_background():
	var screen = get_viewport().get_visible_rect().size
	var tile_size = 48
	var cols = int(screen.x / tile_size) + 2
	var rows = int(screen.y / tile_size) + 2
	dungeon_tiles.columns = cols

	for r in rows:
		for c in cols:
			var rect = ColorRect.new()
			rect.custom_minimum_size = Vector2(tile_size - 1, tile_size - 1)
			var base = TILE_COLORS[randi() % TILE_COLORS.size()]
			var v = randf_range(-0.02, 0.02)
			rect.color = Color(base.r + v, base.g + v, base.b + v, 1.0)
			dungeon_tiles.add_child(rect)

# ——— EMBER PARTICLES ———
func _setup_embers():
	var screen = get_viewport().get_visible_rect().size
	var mat = ParticleProcessMaterial.new()
	mat.direction = Vector3(0, -1, 0)
	mat.spread = 60.0
	mat.gravity = Vector3(0, -25, 0)
	mat.initial_velocity_min = 15.0
	mat.initial_velocity_max = 50.0
	mat.scale_min = 2.0
	mat.scale_max = 4.0
	mat.color = Color(0.95, 0.22, 0.04, 0.9)
	embers.process_material = mat
	embers.emitting = true
	# Spawn along the bottom of the screen
	embers.position = Vector2(screen.x * 0.5, screen.y + 10)
	embers.amount = 50
	embers.lifetime = 5.0
	embers.explosiveness = 0.0
	embers.randomness = 1.0

# ——— PLAYER SPRITE (single frame only) ———
func _setup_player_sprite():
	var tex = load("res://GAME ASSETS/PLAYER SPRITE_FINAL.png")
	if tex == null:
		player_showcase.visible = false
		return

	# Use AtlasTexture to cut out just the first frame
	# Your sprite sheet is 2 columns x 2 rows = 4 frames
	# Each frame is roughly half the image width and height
	var img_w = tex.get_width()   # e.g. 512
	var img_h = tex.get_height()  # e.g. 512
	var frame_w = img_w / 2.0
	var frame_h = img_h / 2.0

	var atlas = AtlasTexture.new()
	atlas.atlas = tex
	# Top-left frame (first idle frame)
	atlas.region = Rect2(0, 0, frame_w, frame_h)

	player_showcase.texture = atlas
	player_showcase.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	# Make the knight larger and centered on the left half
	player_showcase.custom_minimum_size = Vector2(280, 280)

# ——— ANIMATE TITLE PULSE ———
func _process(delta):
	title_pulse_time += delta
	var pulse = sin(title_pulse_time * 1.8) * 0.06 + 0.94
	title_label.modulate = Color(pulse, pulse * 0.09, pulse * 0.09, 1.0)

# ——— BUTTON FUNCTIONS ———
func _on_play_pressed():
	get_tree().change_scene_to_file("res://Scenes/loading_screen.tscn")

func _on_credits_pressed():
	credits_overlay.visible = true

func _on_close_credits_pressed():
	credits_overlay.visible = false

func _on_exit_pressed():
	get_tree().quit()

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		if credits_overlay.visible:
			credits_overlay.visible = false
