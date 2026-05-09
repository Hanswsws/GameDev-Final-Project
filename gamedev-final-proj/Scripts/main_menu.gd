extends Control

@onready var play_button       = $PlayButton
@onready var credits_button    = $CreditsButton
@onready var exit_button       = $ExitButton
@onready var credits_overlay   = $CreditsOverlay
@onready var close_credits_btn = $CreditsOverlay/Panel/VBox/CloseCreditsButton
@onready var embers            = $Embers
@onready var player_showcase   = $PlayerShowcase
@onready var title_label       = $TitleLabel
@onready var btn_sfx: AudioStreamPlayer2D= $btn_sfx


var title_pulse_time = 0.0

func _ready():
	Musicmanager.play_menu_music()
	play_button.pressed.connect(_on_play_pressed)
	credits_button.pressed.connect(_on_credits_pressed)
	exit_button.pressed.connect(_on_exit_pressed)
	close_credits_btn.pressed.connect(_on_close_credits_pressed)
	credits_overlay.visible = false
	_setup_embers()
	_setup_player_sprite()

func _setup_embers():
	var mat = ParticleProcessMaterial.new()
	mat.direction = Vector3(0, -1, 0)
	mat.spread = 55.0
	mat.gravity = Vector3(0, -28, 0)
	mat.initial_velocity_min = 20.0
	mat.initial_velocity_max = 55.0
	mat.scale_min = 2.5
	mat.scale_max = 5.0
	mat.color = Color(0.95, 0.22, 0.04, 0.9)
	embers.process_material = mat
	embers.emitting = true

func _setup_player_sprite():
	var tex = load("res://GAME ASSETS/PLAYER SPRITE_FINAL.png")
	if tex == null:
		player_showcase.visible = false
		return
	# Cut out just the top-left frame from the 2x2 spritesheet
	var atlas = AtlasTexture.new()
	atlas.atlas = tex
	atlas.region = Rect2(0, 0, tex.get_width() / 2.0, tex.get_height() / 2.0)
	player_showcase.texture = atlas
	player_showcase.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED

func _process(delta):
	title_pulse_time += delta
	var pulse = sin(title_pulse_time * 1.8) * 0.06 + 0.94
	title_label.modulate = Color(pulse, pulse * 0.09, pulse * 0.09, 1.0)

func _on_play_pressed():
	btn_sfx.play()
	Musicmanager.play_battle_music()
	await get_tree().create_timer(0.3).timeout
	get_tree().change_scene_to_file("res://Scenes/loading_screen.tscn")
func _on_credits_pressed():
	credits_overlay.visible = true
	btn_sfx.play()
func _on_close_credits_pressed():
	credits_overlay.visible = false
	btn_sfx.play()
func _on_exit_pressed():
	get_tree().quit()
	btn_sfx.play()

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		if credits_overlay.visible:
			credits_overlay.visible = false
