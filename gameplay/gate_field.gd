extends Node2D
class_name GateField

const SHEEP = preload("uid://c6fa3ik7hdw4n")

@onready var open_gate_ui: TextureRect = $OpenGate
@onready var close_gate_ui: TextureRect = $CloseGate

var spot_mapping: Array[int]
var real_sheep_store: Array[Sheep]

signal inspect(sheep: Sheep)

func spawn_sheep(wool_spot_rule: Sheep.WoolSpot, neck_tag_rule: Sheep.NeckTag, tail_type_rule: Sheep.TailType) -> Dictionary:
	spot_mapping.clear()
	real_sheep_store.clear()
	for i in range(25): spot_mapping.append(i)
	spot_mapping.shuffle()
	
	var total_sheep = randi_range(6, 14)
	var base_imposters = randi_range(2, 5)
	
	@warning_ignore("integer_division")
	var bonus = Globals.wave / 3
	
	var imposter_count = min(base_imposters + bonus, total_sheep - 2)
	var real_sheep_count = total_sheep - imposter_count
	
	var spawn_spot = 0
	
	for i in range(imposter_count):
		var imposter: Sheep = SHEEP.instantiate()
		imposter.position = _generate_spawn_position(spawn_spot)
		imposter.inspect.connect(_inspect_sheep)
		_initialize_sheep(imposter, false, wool_spot_rule, neck_tag_rule, tail_type_rule)
		get_parent().add_child.call_deferred(imposter)
		
		spawn_spot += 1
	
	for i in range(real_sheep_count):
		var real_sheep: Sheep = SHEEP.instantiate()
		real_sheep.position = _generate_spawn_position(spawn_spot)
		real_sheep.inspect.connect(_inspect_sheep)
		_initialize_sheep(real_sheep, true, wool_spot_rule, neck_tag_rule, tail_type_rule)
		get_parent().add_child.call_deferred(real_sheep)
		
		spawn_spot += 1
		real_sheep_store.append(real_sheep)
	
	return {
		"total_sheep": total_sheep,
		"imposter_count": imposter_count
	}

func open_gate(wool_spot_rule: Sheep.WoolSpot, neck_tag_rule: Sheep.NeckTag, tail_type_rule: Sheep.TailType):
	open_gate_ui.visible = true
	close_gate_ui.visible = false
	
	var should_exit_gate = randi_range(0, 1) == 0
	if should_exit_gate or true:
		var exit_gate_amount = randi_range(1, 4)
		while exit_gate_amount > 0 and not real_sheep_store.is_empty():
			var sheep_to_exit = real_sheep_store.pick_random()
			real_sheep_store.erase(sheep_to_exit)
			if is_instance_valid(sheep_to_exit) and not sheep_to_exit.inspecting:
				sheep_to_exit.exit_gate()
				exit_gate_amount -= 1
	
	var new_sheep_count = randi_range(1, 5)
	var new_imposter_count = roundi(new_sheep_count * randf_range(0.4, 0.6))
	
	var spawn_spot = 0
	
	for i in range(new_imposter_count):
		var imposter: Sheep = SHEEP.instantiate()
		imposter.enter_gate(spawn_spot)
		imposter.inspect.connect(_inspect_sheep)
		_initialize_sheep(imposter, false, wool_spot_rule, neck_tag_rule, tail_type_rule)
		get_parent().add_child.call_deferred(imposter)
		
		spawn_spot += 1
	
	for i in range(new_sheep_count - new_imposter_count):
		var real_sheep: Sheep = SHEEP.instantiate()
		real_sheep.enter_gate(spawn_spot)
		real_sheep.inspect.connect(_inspect_sheep)
		_initialize_sheep(real_sheep, true, wool_spot_rule, neck_tag_rule, tail_type_rule)
		get_parent().add_child.call_deferred(real_sheep)
		
		spawn_spot += 1
		real_sheep_store.append(real_sheep)

func close_gate():
	open_gate_ui.visible = false
	close_gate_ui.visible = true

func _inspect_sheep(sheep: Sheep): inspect.emit(sheep)

func _initialize_sheep(sheep: Sheep, real_sheep: bool, wool_spot_rule: Sheep.WoolSpot, neck_tag_rule: Sheep.NeckTag, tail_type_rule: Sheep.TailType):
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

func _generate_spawn_position(spot: int) -> Vector2:
	var actual_spot = spot_mapping[spot]
	@warning_ignore("integer_division")
	var y_pos = 832 + (actual_spot / 5) * 102.4 + randf_range(-25.6, 25.6) / 2 + 51.2
	var x_pos = 1728 + (actual_spot % 5) * 166.4 + randf_range(-41.6, 41.6) / 2 + 83.2
	return Vector2(x_pos, y_pos)
