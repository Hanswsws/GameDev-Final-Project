extends CanvasLayer

@onready var settings_button  = $SettingsButton
@onready var settings_overlay = $SettingsOverlay
@onready var death_overlay    = $DeathOverlay

func _ready():
	settings_button.pressed.connect(_on_settings_pressed)
	settings_overlay.process_mode = Node.PROCESS_MODE_ALWAYS
	death_overlay.process_mode    = Node.PROCESS_MODE_ALWAYS

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		if death_overlay.visible:
			return
		if settings_overlay.visible:
			settings_overlay.close_settings()
		else:
			settings_overlay.open_settings()

func _on_settings_pressed():
	if settings_overlay.visible:
		settings_overlay.close_settings()
	else:
		settings_overlay.open_settings()

func show_death_screen():
	death_overlay.show_death_screen()

func show_win_screen():
	death_overlay.show_win_screen()

func show_end_screen():
	death_overlay.show_end_screen()
