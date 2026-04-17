extends CharacterBody2D
class_name Sheep

enum WoolSpot { BROWN, BLACK, NOTHING }
enum NeckTag { RED, BLUE, GREEN }
enum TailType { NOTHING, LONG, SHORT }

signal inspect(sheep: Sheep)

@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var navigation_agent_2d: NavigationAgent2D = $NavigationAgent2D

var remaining_time: float = 0
var inspecting: bool = false
var inspectable: bool = true

var wool_spot: WoolSpot
var neck_tag: NeckTag
var tail_type: TailType

func un_inspect():
	inspecting = false

func exit_gate():
	inspectable = false
	navigation_agent_2d.target_position = Vector2(-1280, 720)
	navigation_agent_2d.target_reached.connect(queue_free)
	set_collision_layer_value(1, false)
	set_collision_mask_value(1, false)
	set_collision_mask_value(5, false)
	set_collision_layer_value(2, true)
	set_collision_mask_value(2, true)

func enter_gate(spawn_spot: int):
	inspectable = false
	position = Vector2(-(spawn_spot + 1) * 128, 1088)
	
	await ready
	
	@warning_ignore("integer_division")
	navigation_agent_2d.target_position = Vector2(spawn_spot / 5 * 166.4 + 1778, spawn_spot % 5 * 102.4 + 882)
	navigation_agent_2d.target_desired_distance = 50
	navigation_agent_2d.target_reached.connect(
		func():
			set_collision_mask_value(5, true)
			inspectable = true
	)
	set_collision_layer_value(1, false)
	set_collision_mask_value(1, false)
	set_collision_mask_value(5, false)
	set_collision_layer_value(3, true)
	set_collision_mask_value(3, true)

func _ready() -> void:
	remaining_time = randf_range(-1, 2)
	velocity = Vector2.from_angle(randf_range(0, TAU)) * randf_range(100, 150)

func _physics_process(delta: float) -> void:
	if navigation_agent_2d.target_position != Vector2.ZERO and not navigation_agent_2d.is_target_reached():
		velocity = global_position.direction_to(navigation_agent_2d.get_next_path_position()) * 150
	else:
		remaining_time -= delta
		
		if remaining_time < 0:
			remaining_time = randf_range(1, 3)
			
			if velocity == Vector2.ZERO:
				velocity = Vector2.from_angle(randf_range(0, TAU)) * randf_range(100, 150)
			else:
				velocity = Vector2.ZERO
	
	if not inspecting:
		move_and_slide()

func _on_texture_button_pressed() -> void:
	if not inspectable: return
	
	inspecting = true
	
	inspect.emit(self)
