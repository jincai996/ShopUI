extends Control

var _selected_armor: Button = null
var _armor_rows: Array[Button] = []
var _armor_buy: Button = null
var _total_coin_label: Label = null
var _parameters_grid: GridContainer = null
var _coins := 0
var _armor_total := 0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_setup_armor_buttons()


func _setup_armor_buttons() -> void:
	var armor: Node = get_node_or_null("HBoxContainer/Buy/TabContainer/Armor")
	if armor == null:
		return
	var vbox: VBoxContainer = armor.get_node("VBoxContainer")
	for child in vbox.get_children():
		if child is Button and child.has_node("Item/Quantity"):
			var item: HBoxContainer = child.get_node("Item")
			item.mouse_filter = Control.MOUSE_FILTER_IGNORE
			for sub in item.get_children():
				if sub is Control and not sub is Button:
					sub.mouse_filter = Control.MOUSE_FILTER_IGNORE
			child.gui_input.connect(_on_armor_button_gui_input.bind(child))
			child.get_node("Item/Quantity/+").pressed.connect(_on_armor_plus_pressed.bind(child))
			child.get_node("Item/Quantity/-").pressed.connect(_on_armor_minus_pressed.bind(child))
			_armor_rows.append(child)
			_update_armor_row_state(child)
	_armor_buy = get_node_or_null("HBoxContainer/PanelContainer/Margin/VBoxContainer/Buy") as Button
	if _armor_buy != null:
		_armor_buy.pressed.connect(_on_armor_buy_pressed)
	_total_coin_label = get_node_or_null("HBoxContainer/Player/PlayerInformation/Equipment&&Skill/PlayerPhoto/TotalCoin") as Label
	if _total_coin_label != null:
		_coins = _total_coin_label.text.get_slice(":", 1).strip_edges().to_int()
	_parameters_grid = get_node_or_null("HBoxContainer/Player/PlayerInformation/Parameters") as GridContainer
	_update_armor_total()


func _on_armor_button_gui_input(event: InputEvent, row: Button) -> void:
	if not (event is InputEventMouseButton) or not event.pressed:
		return
	if event.button_index == MOUSE_BUTTON_LEFT:
		if row == _selected_armor:
			_deselect_armor(row, false)
		else:
			_select_armor(row)
		accept_event()
	elif event.button_index == MOUSE_BUTTON_RIGHT:
		_deselect_armor(row)
		accept_event()


func _update_armor_row_state(row: Button) -> void:
	var disabled: bool = int(row.get_node("Item/Hold").text) <= 0
	row.disabled = disabled
	row.get_node("Item/Quantity/+").disabled = disabled
	row.get_node("Item/Quantity/-").disabled = disabled


func _on_armor_plus_pressed(row: Button) -> void:
	var quantity: Label = row.get_node("Item/Quantity")
	var hold: int = int(row.get_node("Item/Hold").text)
	var value: int = min(int(quantity.text) + 1, hold)
	quantity.text = str(value)
	_update_armor_total()


func _on_armor_minus_pressed(row: Button) -> void:
	var quantity: Label = row.get_node("Item/Quantity")
	var value: int = int(quantity.text) - 1
	if value <= 0:
		_deselect_armor(row)
	else:
		quantity.text = str(value)
	_update_armor_total()


func _select_armor(row: Button) -> void:
	if _selected_armor != null and _selected_armor != row:
		_deselect_armor(_selected_armor, false)
	_selected_armor = row
	var quantity: Label = row.get_node("Item/Quantity")
	if int(quantity.text) <= 0:
		quantity.text = str(min(1, int(row.get_node("Item/Hold").text)))
	_update_armor_total()
	_update_parameter_change(row)


func _deselect_armor(row: Button, reset_quantity: bool = true) -> void:
	if reset_quantity:
		row.get_node("Item/Quantity").text = "0"
	if _selected_armor == row:
		_selected_armor = null
		_reset_parameter_change()
	_update_armor_total()


func _update_armor_total() -> void:
	if _armor_buy == null:
		return
	var total := 0
	for row in _armor_rows:
		var quantity := int(row.get_node("Item/Quantity").text)
		if quantity > 0:
			total += quantity * int(row.get_node("Item/Price").text)
	_armor_total = total
	_armor_buy.text = str(total) if total > 0 else "Buy"
	if total > _coins:
		_armor_buy.disabled = true
		_armor_buy.add_theme_color_override("font_color", Color.RED)
		_armor_buy.add_theme_color_override("font_disabled_color", Color.RED)
	else:
		_armor_buy.disabled = false
		_armor_buy.remove_theme_color_override("font_color")
		_armor_buy.remove_theme_color_override("font_disabled_color")


func _update_parameter_change(row: Button) -> void:
	if _parameters_grid == null:
		return
	var description: String = row.get_node("Item/Decription").text
	var regex := RegEx.new()
	regex.compile("([A-Za-z]+)\\s*([+-])\\s*(\\d+)")
	var result := regex.search(description)
	if result == null:
		_reset_parameter_change()
		return
	var para_name: String = result.get_string(1)
	var value: int = int(result.get_string(2) + result.get_string(3))
	for para in _parameters_grid.get_children():
		var para_name_label := para.get_node_or_null("ParaName") as Label
		if para_name_label == null or para_name_label.text != para_name:
			continue
		var change_label := para.get_node_or_null("ChangeValue") as Label
		if change_label == null:
			continue
		var sign := "+" if value >= 0 else "-"
		change_label.text = sign + " " + str(abs(value))
		if value > 0:
			change_label.add_theme_color_override("font_color", Color.RED)
		elif value < 0:
			change_label.add_theme_color_override("font_color", Color.GREEN)
		break


func _reset_parameter_change() -> void:
	if _parameters_grid == null:
		return
	for para in _parameters_grid.get_children():
		var change_label := para.get_node_or_null("ChangeValue") as Label
		if change_label != null:
			change_label.text = ""
			change_label.remove_theme_color_override("font_color")


func _on_armor_buy_pressed() -> void:
	if _armor_total <= 0 or _armor_total > _coins:
		return
	_coins -= _armor_total
	if _total_coin_label != null:
		_total_coin_label.text = "Coins:" + str(_coins)
	for row in _armor_rows:
		var hold: Label = row.get_node("Item/Hold")
		var quantity := int(row.get_node("Item/Quantity").text)
		if quantity > 0:
			hold.text = str(max(int(hold.text) - quantity, 0))
		row.get_node("Item/Quantity").text = "0"
		_update_armor_row_state(row)
	_selected_armor = null
	_reset_parameter_change()
	_update_armor_total()
