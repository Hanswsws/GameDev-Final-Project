extends CanvasLayer

# ——— Node references ———
@onready var settings_button   = $SettingsButton
@onready var settings_overlay  = $SettingsOverlay
@onready var death_overlay     = $DeathOverlay

func _ready():
	settings_button.pressed.connect(_on_settings_pressed)

	# Make both overlays process even when game is paused
	# (so buttons still work when get_tree().paused = true)
	settings_overlay.process_mode = Node.PROCESS_MODE_ALWAYS
	death_overlay.process_mode    = Node.PROCESS_MODE_ALWAYS

func _input(event):
	# Allow Escape key to toggle settings/pause
	if event.is_action_pressed("ui_cancel"):
		if death_overlay.visible:
			return  # Escape does nothing on death screen
		if settings_overlay.visible:
			settings_overlay.close_settings()
		else:
			settings_overlay.open_settings()

func _on_settings_pressed():
	if settings_overlay.visible:
		settings_overlay.close_settings()
	else:
		settings_overlay.open_settings()

# ——— Called by player.gd when the player dies ———
func show_death_screen():
	death_overlay.show_death_screen()
