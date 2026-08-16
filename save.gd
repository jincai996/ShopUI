extends Control

const SAVE_PATH := "user://shopui_saves.json"
const AVATAR_PATH := "res://Assets/Human Avatars/Avatars_01.png"

var _slots: Array[Button] = []
var _save_data: Dictionary = {}


func _ready() -> void:
	_setup_slots()
	_load_saves()


func _setup_slots() -> void:
	var box: VBoxContainer = get_node_or_null("CenterContainer/PanelContainer/MarginContainer/VBoxContainer") as VBoxContainer
	if box == null:
		return
	var exit_btn := box.get_node_or_null("Exit") as Button
	if exit_btn != null:
		exit_btn.pressed.connect(_on_exit_pressed)
	for i in range(3):
		var slot := box.get_node_or_null("Slot%d" % (i + 1)) as Button
		if slot != null:
			slot.pressed.connect(_on_slot_pressed.bind(i))
			_slots.append(slot)


func _load_saves() -> void:
	_save_data = {}
	if not FileAccess.file_exists(SAVE_PATH):
		_refresh_slots()
		return
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		_refresh_slots()
		return
	var data = JSON.parse_string(file.get_as_text())
	file.close()
	if data is Dictionary:
		_save_data = data
	_refresh_slots()


func _write_saves() -> void:
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file != null:
		file.store_string(JSON.stringify(_save_data))
		file.close()


func _refresh_slots() -> void:
	for i in _slots.size():
		var slot: Button = _slots[i]
		var data = _save_data.get(str(i))
		if data is Dictionary:
			slot.text = str(data.get("time", ""))
			var avatar: String = str(data.get("avatar", ""))
			if not avatar.is_empty() and ResourceLoader.exists(avatar):
				slot.icon = load(avatar) as Texture2D
			else:
				slot.icon = null
		else:
			slot.text = "Empty Slot %d" % (i + 1)
			slot.icon = null


func _on_slot_pressed(index: int) -> void:
	var time: String = Time.get_datetime_string_from_system()
	_save_data[str(index)] = {"time": time, "avatar": AVATAR_PATH}
	_write_saves()
	_refresh_slots()


func _on_exit_pressed() -> void:
	get_tree().change_scene_to_file("res://main.tscn")
