extends Area2D

var warrior_in_range: bool = false
var _paused_for_dialogue: bool = false

const SHOP_BUY: PackedScene = preload("res://shop_buy.tscn")
const SHOP_SALE: PackedScene = preload("res://shop_sale.tscn")
const SAVE_UI: PackedScene = preload("res://save.tscn")

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended)
	DialogueManager.process_mode = Node.PROCESS_MODE_ALWAYS


func _process(_delta: float) -> void:
	if warrior_in_range and not _paused_for_dialogue and Input.is_action_just_pressed("YES"):
		_paused_for_dialogue = true
		var balloon: CanvasLayer = DialogueManager.show_example_dialogue_balloon(load("res://Dialogue/ShopNPC.dialogue"), "", [self])
		balloon.process_mode = Node.PROCESS_MODE_ALWAYS
		balloon.tree_exited.connect(_on_dialogue_balloon_exited)
		get_tree().paused = true


func _on_dialogue_ended(_resource) -> void:
	_on_dialogue_balloon_exited()


func _on_dialogue_balloon_exited() -> void:
	if not _paused_for_dialogue:
		return
	_paused_for_dialogue = false
	if get_tree() != null:
		get_tree().paused = false


func _on_body_entered(body: Node2D) -> void:
	if body.name == "Warrior":
		warrior_in_range = true

func _on_body_exited(body: Node2D) -> void:
	if body.name == "Warrior":
		warrior_in_range = false

func show_shop_buy() -> void:
	var shop = SHOP_BUY.instantiate()
	shop.set_anchors_preset(Control.PRESET_FULL_RECT)
	var viewport_size = get_viewport().get_visible_rect().size
	shop.size = viewport_size
	get_tree().current_scene.add_child(shop)
	
func show_shop_sell() -> void:
	var shop = SHOP_SALE.instantiate()
	shop.set_anchors_preset(Control.PRESET_FULL_RECT)
	var viewport_size = get_viewport().get_visible_rect().size
	shop.size = viewport_size
	get_tree().current_scene.add_child(shop)


func show_save_load() -> void:
	var save = SAVE_UI.instantiate()
	save.set_anchors_preset(Control.PRESET_FULL_RECT)
	var viewport_size = get_viewport().get_visible_rect().size
	save.size = viewport_size
	get_tree().current_scene.add_child(save)
