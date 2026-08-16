extends Node2D

const STATUS_UI: PackedScene = preload("res://status.tscn")

var _status_ui: Control = null


func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed("MENU"):
		return
	if _status_ui != null and is_instance_valid(_status_ui):
		return
	get_viewport().set_input_as_handled()
	_status_ui = STATUS_UI.instantiate()
	_status_ui.process_mode = Node.PROCESS_MODE_ALWAYS
	_status_ui.set_anchors_preset(Control.PRESET_FULL_RECT)
	_status_ui.size = get_viewport().get_visible_rect().size
	add_child(_status_ui)
	get_tree().paused = true
