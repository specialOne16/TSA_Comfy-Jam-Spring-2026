extends Node2D
class_name GateField

const SHEEP = preload("uid://c6fa3ik7hdw4n")

signal inspect(sheep: Sheep)

var wave_number: int = 0

func spawn_sheep(wool_spot_rule: Sheep.WoolSpot, neck_tag_rule: Sheep.NeckTag, tail_type_rule: Sheep.TailType) -> Dictionary:
	var total_sheep = randi_range(6, 14)
	var base_imposters = randi_range(2, 5)
	
	@warning_ignore("integer_division")
	var bonus = wave_number / 3
	
	var imposter_count = min(base_imposters + bonus, total_sheep - 2)
	var real_sheep_count = total_sheep - imposter_count
	
	for i in range(imposter_count):
		var imposter: Sheep = SHEEP.instantiate()
		imposter.position = Vector2(randf_range(640, 2560 - 640), randf_range(360, 1440 - 360))
		imposter.inspect.connect(_inspect_sheep)
		initialize_sheep(imposter, false, wool_spot_rule, neck_tag_rule, tail_type_rule)
		get_parent().add_child.call_deferred(imposter)
	
	for i in range(real_sheep_count):
		var real_sheep: Sheep = SHEEP.instantiate()
		real_sheep.position = Vector2(randf_range(640, 2560 - 640), randf_range(360, 1440 - 360))
		real_sheep.inspect.connect(_inspect_sheep)
		initialize_sheep(real_sheep, true, wool_spot_rule, neck_tag_rule, tail_type_rule)
		get_parent().add_child.call_deferred(real_sheep)
	
	return {
		"total_sheep": total_sheep,
		"imposter_count": imposter_count
	}

func _inspect_sheep(sheep: Sheep): inspect.emit(sheep)

func initialize_sheep(sheep: Sheep, real_sheep: bool, wool_spot_rule: Sheep.WoolSpot, neck_tag_rule: Sheep.NeckTag, tail_type_rule: Sheep.TailType):
	var follow_rule_count = randi_range(2, 3) if real_sheep else randi_range(0, 1)
	
	var follow_wool_spot_rule = true if follow_rule_count == 3 else randi_range(0, follow_rule_count) > 0
	if follow_wool_spot_rule:
		sheep.wool_spot = wool_spot_rule
		follow_rule_count -= 1
	else:
		sheep.wool_spot = Sheep.WoolSpot.values().filter(func(r): return r != wool_spot_rule).pick_random()
		assert(sheep.wool_spot != wool_spot_rule)
	
	var follow_neck_tag_rule = true if follow_rule_count == 2 else randi_range(0, follow_rule_count) > 0
	if follow_neck_tag_rule:
		sheep.neck_tag = neck_tag_rule
		follow_rule_count -= 1
	else:
		sheep.neck_tag = Sheep.NeckTag.values().filter(func(r): return r != neck_tag_rule).pick_random()
		assert(sheep.neck_tag != neck_tag_rule)
	
	var follow_tail_type_rule = true if follow_rule_count == 1 else randi_range(0, follow_rule_count) > 0
	if follow_tail_type_rule:
		sheep.tail_type = tail_type_rule
		follow_rule_count -= 1
	else:
		sheep.tail_type = Sheep.TailType.values().filter(func(r): return r != tail_type_rule).pick_random()
		assert(sheep.tail_type != tail_type_rule)
	
	assert(follow_rule_count == 0)
	
	if not real_sheep: sheep.modulate = Color.RED
