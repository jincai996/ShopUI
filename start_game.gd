extends Control

@onready var v_box_container: VBoxContainer = $VBoxContainer

var _hovered_button: Button = null


func _ready() -> void:
	await get_tree().process_frame
	for child in v_box_container.get_children():
		if child is Button:
			child.pivot_offset = child.size / 2.0
			child.mouse_entered.connect(_on_button_mouse_entered.bind(child))
			child.mouse_exited.connect(_on_button_mouse_exited.bind(child))
			child.pressed.connect(_on_button_press.bind(child))


func _on_button_mouse_entered(button: Button) -> void:
	_hovered_button = button
	var tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.tween_property(button, "scale", Vector2(1.5, 1.5), 0.2)


func _on_button_mouse_exited(button: Button) -> void:
	if _hovered_button == button:
		_hovered_button = null
	var tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.tween_property(button, "scale", Vector2(1.0, 1.0), 0.15)

func _on_button_press(button: Button) -> void:
	print(button.name)
