extends Area2D

var warrior_in_range: bool = false

const SHOP: PackedScene = preload("res://shop_ui.tscn")


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _process(_delta: float) -> void:
	if warrior_in_range and Input.is_action_just_pressed("YES"):
		DialogueManager.show_example_dialogue_balloon(load("res://Dialogue/ShopNPC.dialogue"), "", [self])


func _on_body_entered(body: Node2D) -> void:
	if body.name == "Warrior":
		warrior_in_range = true

func _on_body_exited(body: Node2D) -> void:
	if body.name == "Warrior":
		warrior_in_range = false

func show_shop_ui() -> void:
	var shop = SHOP.instantiate()
	shop.set_anchors_preset(Control.PRESET_FULL_RECT)
	var viewport_size = get_viewport().get_visible_rect().size
	shop.size = viewport_size
	get_tree().current_scene.add_child(shop)
