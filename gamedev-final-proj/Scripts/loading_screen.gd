extends Control

@onready var progress_bar   = $CenterContainer/VBoxContainer/ProgressBar
@onready var loading_label  = $CenterContainer/VBoxContainer/LoadingLabel
@onready var tip_label      = $CenterContainer/VBoxContainer/TipLabel
@onready var title_label    = $CenterContainer/VBoxContainer/TitleLabel
@onready var dungeon_tiles  = $DungeonTiles
@onready var embers         = $Embers

const GAME_SCENE = "res://Scenes/gamemap.tscn"

const TILE_COLORS = [
	Color(0.18, 0.17, 0.16, 1),
	Color(0.15, 0.14, 0.13, 1),
	Color(0.20, 0.19, 0.18, 1),
	Color(0.13, 0.12, 0.11, 1),
	Color(0.22, 0.20, 0.19, 1),
]

var tips = [
	"Move aggressively to boost your attack power.",
	"Staying defensive regenerates your health over time.",
	"Your movement style evolves your abilities automatically.",
	"Enemies get faster and stronger with each wave.",
	"Keep moving — standing still is dangerous!",
]

var title_pulse_time = 0.0

func _ready():
	tip_label.text = "Tip: " + tips[randi() % tips.size()]
	_build_dungeon_background()
	_setup_embers()
	ResourceLoader.load_threaded_request(GAME_SCENE)

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
			var variation = randf_range(-0.02, 0.02)
			rect.color = Color(base.r + variation, base.g + variation, base.b + variation, 1.0)
			dungeon_tiles.add_child(rect)

func _setup_embers():
	var mat = ParticleProcessMaterial.new()
	mat.direction = Vector3(0, -1, 0)
	mat.spread = 35.0
	mat.gravity = Vector3(0, -30, 0)
	mat.initial_velocity_min = 20.0
	mat.initial_velocity_max = 60.0
	mat.scale_min = 1.5
	mat.scale_max = 3.5
	mat.color = Color(0.9, 0.25, 0.05, 0.85)
	embers.process_material = mat
	embers.emitting = true
	embers.position = Vector2(get_viewport().get_visible_rect().size.x * 0.5,
							  get_viewport().get_visible_rect().size.y + 20)

func _process(delta):
	# Pulse the title just like the main menu
	title_pulse_time += delta
	var pulse = sin(title_pulse_time * 1.8) * 0.06 + 0.94
	title_label.modulate = Color(pulse, pulse * 0.09, pulse * 0.09, 1.0)

	# Handle loading progress
	var progress = []
	var status = ResourceLoader.load_threaded_get_status(GAME_SCENE, progress)
	match status:
		ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			progress_bar.value = progress[0] * 100
			loading_label.text = "Loading... " + str(int(progress[0] * 100)) + "%"
		ResourceLoader.THREAD_LOAD_LOADED:
			progress_bar.value = 100
			loading_label.text = "Ready!"
			await get_tree().create_timer(0.3).timeout
			var scene = ResourceLoader.load_threaded_get(GAME_SCENE)
			get_tree().change_scene_to_packed(scene)
		ResourceLoader.THREAD_LOAD_FAILED:
			loading_label.text = "Error loading game!"
			loading_label.modulate = Color(1, 0.2, 0.2, 1)
