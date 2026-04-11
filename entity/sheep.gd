extends CharacterBody2D
class_name Sheep

enum WoolSpot { WHITE, BROWN, BLACK, NOTHING }
enum NeckTag { RED, BLUE, GREEN }
enum TailType { FAT, LONG, SHORT }

signal inspect(sheep: Sheep)

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

var remaining_time: float = 0
var inspecting: bool = false

var wool_spot: WoolSpot
var neck_tag: NeckTag
var tail_type: TailType

func un_inspect():
	inspecting = false
	sprite_2d.visible = false

func _ready() -> void:
	sprite_2d.visible = false
	
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
	sprite_2d.visible = true
	
	inspect.emit(self)
