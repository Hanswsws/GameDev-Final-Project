extends Node

@onready var menu = $menumusic
@onready var battle = $battlemusic
@onready var boss = $bossmusic

var current_music : AudioStreamPlayer = null

const FADE_TIME = 1.5
const MUSIC_VOLUME = -40.0


func _ready():
	menu.volume_db = MUSIC_VOLUME
	battle.volume_db = MUSIC_VOLUME
	boss.volume_db = MUSIC_VOLUME


func switch_music(new_music: AudioStreamPlayer):

	if current_music == new_music:
		return

	# Fade out current music
	if current_music and current_music.playing:
		var fade_out = create_tween()
		fade_out.tween_property(
			current_music,
			"volume_db",
			-80,
			FADE_TIME
		)

		await fade_out.finished
		current_music.stop()

	# Prepare new music
	new_music.volume_db = -80

	if not new_music.playing:
		new_music.play()

	# Fade in new music
	var fade_in = create_tween()
	fade_in.tween_property(
		new_music,
		"volume_db",
		MUSIC_VOLUME,
		FADE_TIME
	)

	current_music = new_music


func play_menu_music():
	switch_music(menu)


func play_battle_music():
	switch_music(battle)


func play_boss_music():
	switch_music(boss)
