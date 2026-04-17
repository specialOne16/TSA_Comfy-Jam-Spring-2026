extends Node2D

const GATE_OPEN_TRIGGER = [0.4, 0.6, 0.8]
const TOSS = ["kick", "shoot"]
const WIN = ["win_1", "win_2"]
const LOSE = ["lose_1", "lose_2"]

@onready var gate_field: GateField = $GateField
@onready var inspection: Inspection = $Inspection

@onready var tsa_rule_label: Label = $Control/TsaBoard/TsaRuleLabel
@onready var wave_stat_label: Label = $Control/VBoxContainer/WaveStatLabel
@onready var next_wave_button: Button = $Control/NextWaveButton
@onready var restart_wave_button: Button = $Control/RestartWaveButton
@onready var animated_sprite_2d: AnimatedSprite2D:
	get():
		if animated_sprite_2d == null:
			animated_sprite_2d = ResourceLoader.load_threaded_get("uid://b5lo1jvsbpgwb").instantiate()
			add_child(animated_sprite_2d)
			animated_sprite_2d.z_index = 5
		return animated_sprite_2d

var wool_spot_rule: Sheep.WoolSpot
var neck_tag_rule: Sheep.NeckTag
var tail_type_rule: Sheep.TailType

var imposter_count = 0
var gate_opened = 0
var animation_playing = false

var real_sheep_tossed = 0
var imposter_tossed = 0

func _ready() -> void:
	gate_field.inspect.connect(_try_inspect)
	next_wave_button.visible = false
	restart_wave_button.visible = false
	
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
	
	ResourceLoader.load_threaded_request("uid://b5lo1jvsbpgwb")


func _on_inspection_sheep_tossed(sheep: Sheep) -> void:
	var follow_rule_count = 0
	
	if sheep.wool_spot == wool_spot_rule: follow_rule_count += 1
	if sheep.neck_tag == neck_tag_rule: follow_rule_count += 1
	if sheep.tail_type == tail_type_rule: follow_rule_count += 1
	
	if follow_rule_count >= 2: real_sheep_tossed += 1
	else: imposter_tossed += 1
	
	wave_stat_label.text = "Tossed: %d real sheep, %d imposter" % [real_sheep_tossed, imposter_tossed]
	
	animated_sprite_2d.visible = true
	animated_sprite_2d.play(TOSS.pick_random())
	animation_playing = true
	await animated_sprite_2d.animation_finished
	animation_playing = false
	animated_sprite_2d.visible = false
	
	if imposter_tossed < imposter_count:
		if float(imposter_tossed) / imposter_count >= GATE_OPEN_TRIGGER[gate_opened]:
			gate_opened += 1
			gate_field.open_gate(wool_spot_rule, neck_tag_rule, tail_type_rule)
			
	
	if imposter_tossed >= imposter_count:
		gate_field.inspect.disconnect(_try_inspect)
		
		animated_sprite_2d.visible = true
		animated_sprite_2d.play(WIN.pick_random())
		animation_playing = true
		await animated_sprite_2d.animation_finished
		animation_playing = false
		animated_sprite_2d.visible = false
	
		next_wave_button.visible = true
	
	if real_sheep_tossed >= 2:
		gate_field.inspect.disconnect(_try_inspect)
		
		animated_sprite_2d.visible = true
		animated_sprite_2d.play(LOSE.pick_random())
		animation_playing = true
		await animated_sprite_2d.animation_finished
		animation_playing = false
		animated_sprite_2d.visible = false
		
		restart_wave_button.visible = true

func _try_inspect(s): if not animation_playing: inspection.inspect(s)

func _on_next_wave_button_pressed() -> void:
	Globals.wave += 1
	get_tree().reload_current_scene()


func _on_restart_wave_button_pressed() -> void:
	get_tree().reload_current_scene()
