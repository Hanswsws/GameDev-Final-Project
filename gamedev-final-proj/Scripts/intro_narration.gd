extends Control

# ─── Narration Pages ────────────────────────────────────────────────────────
const PAGES := [
	"It seems...\nyou are trapped here...",

	"The thing you call time no longer flows\nthe way you believe it should.",

	"A place where fragments of worlds, timelines,\nand forgotten realities collide without warning.\n\nKingdoms swallowed whole.\nCreatures torn from distant eras.\nRuins of civilizations that may not have even existed anymore.",

	"They all end up here.\n\nThe V.O.I.D.\n— the Volatile Omniversal Intersection of Dimensions.",

	"No one knows when it began.\nNo one knows if there is an end.\n\nAt least... no one from your plane of existence does.",

	"Though I doubt your kind could even comprehend it,\nwith how infinitesimally naive you all are.",

	"Those who survive long enough\nbegin to understand one thing:\n\nThe V.O.I.D. does not care who you were before you arrived.",

	"Knight, king, mercenary, beast —\nit makes no difference here.\n\nYour titles are worthless.\nYour world is gone.",

	"And now, like countless others before you...\n\nthe V.O.I.D. has claimed you as well.",

	"Bound to a force beyond your understanding,\nyour weapons continuously shift between what you call\na sword, bow, and gun,\nforcing you to adapt against the horrors\nlurking within the dungeon's depths.",

	"And perhaps somewhere beneath the endless ruins\nand collapsing realities...\n\nsomething is waiting.\n\nis watching...",

	"something....\n\nremains.\n\nor someone...",
]

# ─── Typing speed ─────────────────────────────────────────────────────────────
const CHARS_PER_SEC  := 38.0
const FAST_CHARS_PER_SEC := 120.0
const FADE_DURATION  := 0.55   # seconds for page cross-fade
const VIGNETTE_PULSE := 0.6    # how strongly vignette breathes

# ─── Node references ──────────────────────────────────────────────────────────
@onready var overlay        : ColorRect   = $Overlay
@onready var text_label     : RichTextLabel = $CenterContainer/VBox/NarrationLabel
@onready var page_dots      : HBoxContainer = $PageDots
@onready var continue_hint  : Label        = $ContinueHint
@onready var vignette       : ColorRect    = $Vignette
@onready var particle_left  : GPUParticles2D = $EmberLeft
@onready var particle_right : GPUParticles2D = $EmberRight
@onready var glitch_timer   : Timer        = $GlitchTimer
@onready var flicker_timer  : Timer        = $FlickerTimer

# ─── State ────────────────────────────────────────────────────────────────────
var current_page   := 0
var typed_chars    := 0.0
var full_text      := ""
var typing_done    := false
var is_transitioning := false
var hint_blink_t   := 0.0
var vignette_t     := 0.0
var input_blocked  := false  # brief block after page change

func _ready() -> void:
	_build_dot_indicators()
	_setup_embers()
	overlay.modulate.a = 0.0
	text_label.modulate.a = 0.0
	continue_hint.modulate.a = 0.0
	vignette.modulate.a = 0.0
	glitch_timer.timeout.connect(_do_glitch)
	flicker_timer.timeout.connect(_do_flicker)
	# Fade in the overlay first, then start page 0
	var tw = create_tween()
	tw.tween_property(overlay, "modulate:a", 1.0, 0.8)
	tw.tween_property(vignette, "modulate:a", 1.0, 1.2)
	tw.tween_callback(_begin_page.bind(0))

func _process(delta: float) -> void:
	# Typewriter
	if not typing_done and not is_transitioning:
		var speed = FAST_CHARS_PER_SEC if Input.is_action_pressed("ui_accept") or Input.is_action_pressed("ui_select") else CHARS_PER_SEC
		typed_chars += speed * delta
		var visible_count := mini(int(typed_chars), full_text.length())
		text_label.visible_characters = visible_count
		if visible_count >= full_text.length():
			_on_typing_finished()

	# Hint blink
	if typing_done and not is_transitioning:
		hint_blink_t += delta * 1.8
		continue_hint.modulate.a = (sin(hint_blink_t * PI) * 0.5 + 0.5) * 0.75

	# Vignette slow breathing
	vignette_t += delta * 0.35
	var breath := sin(vignette_t) * VIGNETTE_PULSE * 0.5 + (1.0 - VIGNETTE_PULSE * 0.5)
	vignette.modulate.a = clamp(breath, 0.3, 0.85)

func _input(event: InputEvent) -> void:
	if is_transitioning or input_blocked:
		return
	var advance := false
	if event is InputEventKey:
		if event.pressed and (event.keycode == KEY_SPACE or event.keycode == KEY_ENTER or event.keycode == KEY_KP_ENTER):
			advance = true
	elif event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			advance = true

	if advance:
		if not typing_done:
			# Skip typing — reveal all
			typed_chars = full_text.length() as float
			text_label.visible_characters = full_text.length()
			_on_typing_finished()
		else:
			_advance_page()

# ─── Page logic ───────────────────────────────────────────────────────────────
func _begin_page(index: int) -> void:
	current_page = index
	full_text     = PAGES[index]
	typed_chars   = 0.0
	typing_done   = false
	hint_blink_t  = 0.0
	continue_hint.modulate.a = 0.0

	text_label.text             = full_text
	text_label.visible_characters = 0
	text_label.modulate.a       = 0.0

	_update_dots()

	# Brief flicker-in of the text
	var tw = create_tween()
	tw.tween_property(text_label, "modulate:a", 1.0, FADE_DURATION)
	tw.tween_callback(func(): input_blocked = false)

	# Restart glitch timer occasionally
	glitch_timer.wait_time = randf_range(4.0, 9.0)
	glitch_timer.start()

func _on_typing_finished() -> void:
	typing_done = true
	if current_page == PAGES.size() - 1:
		continue_hint.text = "[ Press SPACE or Click to begin... ]"
	else:
		continue_hint.text = "[ Click or press SPACE to continue ]"

func _advance_page() -> void:
	is_transitioning = true
	input_blocked    = true
	glitch_timer.stop()

	# Fade out current text
	var tw = create_tween()
	tw.tween_property(text_label, "modulate:a", 0.0, FADE_DURATION * 0.8)
	tw.tween_property(continue_hint, "modulate:a", 0.0, FADE_DURATION * 0.5)
	await tw.finished

	if current_page >= PAGES.size() - 1:
		_transition_to_game()
	else:
		is_transitioning = false
		_begin_page(current_page + 1)

func _transition_to_game() -> void:
	# Full black fade-out before loading game
	var tw = create_tween()
	tw.tween_property(overlay, "modulate:a", 1.0, 0.0)   # overlay already visible
	tw.tween_property(vignette, "modulate:a", 0.0, 0.4)
	tw.tween_interval(0.3)
	tw.tween_callback(func():
		Gamemanager.reset_score()
		Musicmanager.play_battle_music()
		get_tree().change_scene_to_file("res://Scenes/loading_screen.tscn")
	)

# ─── Dot indicators ───────────────────────────────────────────────────────────
func _build_dot_indicators() -> void:
	for child in page_dots.get_children():
		child.queue_free()
	for i in range(PAGES.size()):
		var dot := ColorRect.new()
		dot.custom_minimum_size = Vector2(8, 8)
		dot.color = Color(0.3, 0.22, 0.16, 0.6)
		page_dots.add_child(dot)

func _update_dots() -> void:
	var children := page_dots.get_children()
	for i in range(children.size()):
		var dot : ColorRect = children[i]
		if i == current_page:
			dot.color = Color(0.82, 0.12, 0.08, 0.95)
			dot.custom_minimum_size = Vector2(12, 8)
		elif i < current_page:
			dot.color = Color(0.45, 0.18, 0.12, 0.55)
			dot.custom_minimum_size = Vector2(8, 8)
		else:
			dot.color = Color(0.28, 0.20, 0.14, 0.45)
			dot.custom_minimum_size = Vector2(8, 8)

# ─── Ember particles ──────────────────────────────────────────────────────────
func _setup_embers() -> void:
	_configure_emitter(particle_left,  Vector2(-40, 40),  Vector3(-1, -1, 0))
	_configure_emitter(particle_right, Vector2(40,  40),  Vector3(1,  -1, 0))

func _configure_emitter(emitter: GPUParticles2D, origin_offset: Vector2, dir: Vector3) -> void:
	var mat := ParticleProcessMaterial.new()
	mat.direction             = dir
	mat.spread                = 30.0
	mat.gravity               = Vector3(0, -15, 0)
	mat.initial_velocity_min  = 12.0
	mat.initial_velocity_max  = 30.0
	mat.scale_min             = 1.5
	mat.scale_max             = 3.5
	mat.color                 = Color(0.85, 0.16, 0.04, 0.7)
	mat.color_ramp            = _build_ember_gradient()
	emitter.process_material  = mat
	emitter.amount            = 24
	emitter.lifetime          = 3.5
	emitter.emitting          = true

func _build_ember_gradient() -> GradientTexture1D:
	var g := Gradient.new()
	g.set_color(0, Color(0.95, 0.30, 0.05, 0.85))
	g.add_point(0.5, Color(0.60, 0.10, 0.02, 0.5))
	g.add_point(1.0, Color(0.20, 0.05, 0.01, 0.0))
	var gt := GradientTexture1D.new()
	gt.gradient = g
	return gt

# ─── Glitch / flicker effects ─────────────────────────────────────────────────
func _do_glitch() -> void:
	if is_transitioning:
		return
	# Brief offset jitter on text
	var original_pos := text_label.position
	var tw := create_tween()
	tw.tween_property(text_label, "position", original_pos + Vector2(randf_range(-3, 3), randf_range(-2, 2)), 0.04)
	tw.tween_property(text_label, "position", original_pos, 0.04)
	tw.tween_property(text_label, "position", original_pos + Vector2(randf_range(-2, 2), 0), 0.03)
	tw.tween_property(text_label, "position", original_pos, 0.03)
	# Reschedule
	glitch_timer.wait_time = randf_range(5.0, 11.0)
	glitch_timer.start()

func _do_flicker() -> void:
	if is_transitioning:
		return
	var tw := create_tween()
	tw.tween_property(overlay, "modulate:a", randf_range(0.88, 0.97), 0.06)
	tw.tween_property(overlay, "modulate:a", 1.0, 0.06)
	flicker_timer.wait_time = randf_range(6.0, 16.0)
	flicker_timer.start()
