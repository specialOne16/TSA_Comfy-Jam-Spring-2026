extends Node2D
class_name GateField

const SHEEP = preload("uid://c6fa3ik7hdw4n")

signal inspect(sheep: Sheep)

var wave_number: int = 0

func _ready() -> void:
	var total_sheep = 5#randi_range(6, 14)
	var base_imposters = randi_range(2, 5)
	
	@warning_ignore("integer_division")
	var bonus = wave_number / 3
	
	var imposter_count = min(base_imposters + bonus, total_sheep - 2)
	var real_sheep_count = total_sheep - imposter_count
	
	for i in range(imposter_count):
		var imposter: Sheep = SHEEP.instantiate()
		imposter.position = Vector2(randf_range(640, 2560 - 640), randf_range(360, 1440 - 360))
		imposter.inspect.connect(_inspect_sheep)
		get_parent().add_child.call_deferred(imposter)
	
	for i in range(real_sheep_count):
		var real_sheep: Sheep = SHEEP.instantiate()
		real_sheep.position = Vector2(randf_range(640, 2560 - 640), randf_range(360, 1440 - 360))
		real_sheep.inspect.connect(_inspect_sheep)
		get_parent().add_child.call_deferred(real_sheep)

func _inspect_sheep(sheep: Sheep): inspect.emit(sheep)
