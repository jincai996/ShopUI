extends CharacterBody2D

# 临时
const SPEED:int = 300
var direction: Vector2 = Vector2.ZERO	# (1,0)LEFT，(-1,0)RIGHT，(0,-1)UP，(0,1)DOWN
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var state_machine = $AnimationTree.get("parameters/playback") as AnimationNodeStateMachinePlayback


func _ready() -> void:
	animation_tree.active = true
	
func _physics_process(_delta: float) -> void:
	direction = Input.get_vector("LEFT","RIGHT","UP","DOWN").normalized()
	
	match direction:
		# blend_position: -1 LEFT, 1 RIGHT
		Vector2.LEFT:
			animation_tree.set("parameters/RUN/blend_position", -1)
			animation_tree.set("parameters/IDLE/blend_position", -1)
			state_machine.travel('RUN')
			velocity = direction * SPEED
		Vector2.RIGHT:
			animation_tree.set("parameters/RUN/blend_position", 1)
			animation_tree.set("parameters/IDLE/blend_position", 1)
			state_machine.travel('RUN')
			velocity = direction * SPEED
		Vector2.UP:
			state_machine.travel('RUN')
			velocity = direction * SPEED
		Vector2.DOWN:
			state_machine.travel('RUN')
			velocity = direction * SPEED
		Vector2.ZERO:
			state_machine.travel('IDLE')
			velocity = Vector2.ZERO
	
	move_and_slide()
