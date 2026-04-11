extends Node2D

@onready var gate_field: GateField = $GateField
@onready var inspection: Inspection = $Inspection

@onready var tsa_rule_label: Label = $Control/VBoxContainer/TsaRuleLabel
@onready var wave_stat_label: Label = $Control/VBoxContainer/WaveStatLabel
@onready var next_wave_button: Button = $Control/NextWaveButton

var wool_spot_rule: Sheep.WoolSpot
var neck_tag_rule: Sheep.NeckTag
var tail_type_rule: Sheep.TailType

var imposter_count = 0

var real_sheep_tossed = 0
var imposter_tossed = 0

func _ready() -> void:
	gate_field.inspect.connect(inspection.inspect)
	next_wave_button.visible = false
	Globals.wave += 1
	
	wool_spot_rule = Sheep.WoolSpot.values().pick_random()
	neck_tag_rule = Sheep.NeckTag.values().pick_random()
	tail_type_rule = Sheep.TailType.values().pick_random()
	
	var sheep = gate_field.spawn_sheep(wool_spot_rule, neck_tag_rule, tail_type_rule)
	imposter_count = sheep.imposter_count
	tsa_rule_label.text = "Wave: %d (%d sheeps, %d imposters)\nTSA Rule: Wool Spot = %s   Neck Tag = %s   Tail Type = %s" % [
		Globals.wave,
		sheep.total_sheep, 
		sheep.imposter_count,
		Sheep.WoolSpot.keys()[wool_spot_rule],
		Sheep.NeckTag.keys()[neck_tag_rule],
		Sheep.TailType.keys()[tail_type_rule]
	]


func _on_inspection_sheep_tossed(sheep: Sheep) -> void:
	var follow_rule_count = 0
	
	if sheep.wool_spot == wool_spot_rule: follow_rule_count += 1
	if sheep.neck_tag == neck_tag_rule: follow_rule_count += 1
	if sheep.tail_type == tail_type_rule: follow_rule_count += 1
	
	if follow_rule_count >= 2: real_sheep_tossed += 1
	else: imposter_tossed += 1
	
	wave_stat_label.text = "Tossed: %d real sheep, %d imposter" % [real_sheep_tossed, imposter_tossed]
	
	if imposter_tossed >= imposter_count:
		gate_field.inspect.disconnect(inspection.inspect)
		next_wave_button.visible = true
