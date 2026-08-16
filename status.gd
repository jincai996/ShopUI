extends Control

@onready var _package: PanelContainer = $HBoxContainer/Package
@onready var _tab_container: TabContainer = $HBoxContainer/Package/TabContainer
@onready var _equip_weapon: Button = $"HBoxContainer/Player/PlayerInformation/Equipment&&Skill/Equip/Weapon"
@onready var _equip_armor: Button = $"HBoxContainer/Player/PlayerInformation/Equipment&&Skill/Equip/Armor"
@onready var _parameters_grid: GridContainer = $HBoxContainer/Player/PlayerInformation/Parameters

var _hovered_row: Button = null
var _equipped_row: Dictionary = {}
var _slot_effects: Dictionary = {}
var _default_change_texts: Dictionary = {}


func _ready() -> void:
	_equip_weapon.pressed.connect(_show_tab.bind(0))
	_equip_armor.pressed.connect(_show_tab.bind(1))
	_connect_tab_items(_tab_container.get_node("Weapon/VBoxContainer"), _equip_weapon)
	_connect_tab_items(_tab_container.get_node("Armor/VBoxContainer"), _equip_armor)
	_connect_gui_input(_package)
	_equipped_row[_equip_weapon] = null
	_equipped_row[_equip_armor] = null
	_slot_effects[_equip_weapon] = {}
	_slot_effects[_equip_armor] = {}
	for para in _parameters_grid.get_children():
		var name_label := para.get_node_or_null("ParaName") as Label
		var change_label := para.get_node_or_null("ChangeValue") as Label
		if name_label == null or change_label == null:
			continue
		_default_change_texts[name_label.text] = change_label.text


func _show_tab(index: int) -> void:
	_package.visible = true
	_tab_container.current_tab = index


func _connect_tab_items(vbox: VBoxContainer, equip: Button) -> void:
	for child in vbox.get_children():
		if child is Button and child.has_node("Item/Item"):
			child.pressed.connect(_on_item_pressed.bind(child, equip))
			child.mouse_entered.connect(_on_item_mouse_entered.bind(child, equip))
			child.mouse_exited.connect(_on_item_mouse_exited)


func _parse_effect(row: Button) -> Dictionary:
	var effects: Dictionary = {}
	var description: String = row.get_node("Item/Decription").text
	var regex := RegEx.new()
	regex.compile("([A-Za-z]+)\\s*([+-])\\s*(\\d+)")
	var result := regex.search(description)
	if result != null:
		effects[result.get_string(1)] = int(result.get_string(2) + result.get_string(3))
	return effects


func _on_item_pressed(row: Button, equip: Button) -> void:
	equip.icon = (row.get_node("Item/Item") as TextureRect).texture
	if _equipped_row[equip] == row:
		return
	var old_effects: Dictionary = _slot_effects[equip]
	var new_effects: Dictionary = old_effects.duplicate()
	new_effects.merge(_parse_effect(row))
	_apply_effect_delta(old_effects, new_effects)
	_slot_effects[equip] = new_effects
	_equipped_row[equip] = row
	if _hovered_row == row:
		_update_change_display(row, equip)


func _apply_effect_delta(old_effects: Dictionary, new_effects: Dictionary) -> void:
	for para in _parameters_grid.get_children():
		var name_label := para.get_node_or_null("ParaName") as Label
		var value_label := para.get_node_or_null("CurrentValue") as Label
		if name_label == null or value_label == null:
			continue
		var para_name: String = name_label.text
		var delta: int = new_effects.get(para_name, 0) - old_effects.get(para_name, 0)
		if delta != 0:
			value_label.text = str(int(value_label.text) + delta)


func _on_item_mouse_entered(row: Button, equip: Button) -> void:
	_hovered_row = row
	_update_change_display(row, equip)


func _on_item_mouse_exited() -> void:
	_hovered_row = null
	_restore_change_defaults()


func _update_change_display(row: Button, equip: Button) -> void:
	_restore_change_defaults()
	var equipped: Button = _equipped_row[equip]
	if equipped == row:
		return
	var old_effects: Dictionary = {}
	if equipped != null:
		old_effects = _parse_effect(equipped)
	var new_effects: Dictionary = _parse_effect(row)
	for para in _parameters_grid.get_children():
		var name_label := para.get_node_or_null("ParaName") as Label
		var change_label := para.get_node_or_null("ChangeValue") as Label
		if name_label == null or change_label == null:
			continue
		var para_name: String = name_label.text
		var delta: int = new_effects.get(para_name, 0) - old_effects.get(para_name, 0)
		if delta == 0:
			continue
		var sign := "+" if delta > 0 else "-"
		change_label.text = sign + " " + str(abs(delta))
		change_label.add_theme_color_override("font_color", Color.RED if delta > 0 else Color.GREEN)


func _restore_change_defaults() -> void:
	for para in _parameters_grid.get_children():
		var name_label := para.get_node_or_null("ParaName") as Label
		var change_label := para.get_node_or_null("ChangeValue") as Label
		if name_label == null or change_label == null:
			continue
		change_label.text = _default_change_texts.get(name_label.text, "")
		change_label.remove_theme_color_override("font_color")


func _connect_gui_input(node: Node) -> void:
	if node is Control:
		node.gui_input.connect(_on_package_gui_input)
	for child in node.get_children():
		_connect_gui_input(child)


func _on_package_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_RIGHT:
		_package.visible = false
		accept_event()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("MENU"):
		get_viewport().set_input_as_handled()
		get_tree().paused = false
		if get_parent() == get_tree().root:
			get_tree().change_scene_to_file("res://main.tscn")
		else:
			queue_free()
		return
	if not _package.visible:
		return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_RIGHT:
		if _package.get_global_rect().has_point(event.position):
			_package.visible = false
