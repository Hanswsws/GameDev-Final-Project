extends Node

const SAVE_PATH = "user://savegame.cfg"

var _cfg := ConfigFile.new()

func _ready():
	load_data()

func load_data():
	var err = _cfg.load(SAVE_PATH)
	if err != OK:
		_cfg.set_value("levels", "level2_unlocked", false)
		_cfg.set_value("levels", "level2_completed", false)
		save_data()

func save_data():
	_cfg.save(SAVE_PATH)

func is_level2_unlocked() -> bool:
	return _cfg.get_value("levels", "level2_unlocked", false)

func unlock_level2():
	_cfg.set_value("levels", "level2_unlocked", true)
	save_data()
	print("SaveSystem: Level 2 unlocked!")

func complete_level2():
	_cfg.set_value("levels", "level2_completed", true)
	save_data()
	print("SaveSystem: Level 2 completed!")

func is_level2_completed() -> bool:
	return _cfg.get_value("levels", "level2_completed", false)
