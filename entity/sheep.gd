extends CharacterBody2D
class_name Sheep

enum WoolSpot { WHITE, BROWN, BLACK, NOTHING }
enum NeckTag { RED, BLUE, GREEN }
enum TailType { FAT, LONG, SHORT }

signal inspect(sheep: Sheep)

@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

var remaining_time: float = 0
var inspecting: bool = false

var wool_spot: WoolSpot = WoolSpot.values().pick_random()
var neck_tag: NeckTag = NeckTag.values().pick_random()
var tail_type: TailType = TailType.values().pick_random()

func un_inspect():
	inspecting = false
	collision_shape_2d.disabled = false

func _ready() -> void:
	remaining_time = randf_range(-1, 2)
	velocity = Vector2.from_angle(randf_range(0, TAU)) * randf_range(100, 150)

func _physics_process(delta: float) -> void:
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
	inspecting = true
	
	inspect.emit(self)
	collision_shape_2d.disabled = true
