extends Node2D

const GATE_OPEN_TRIGGER = [0.4, 0.6, 0.8]
const TOSS = ["kick", "shoot"]
const WIN = ["win_1", "win_2"]
const LOSE = ["lose_1", "lose_2"]

@onready var gate_field: GateField = $GateField
@onready var inspection: Inspection = $Inspection

@onready var wool_spot_rule_label: Label = $Control/TsaBoard/VBoxContainer/WoolSpotRule
@onready var neck_tag_rule_label: Label = $Control/TsaBoard/VBoxContainer/NeckTagRule
@onready var tail_type_rule_label: Label = $Control/TsaBoard/VBoxContainer/TailTypeRule

@onready var first_mistake: TextureRect = $Control/FirstMistake
@onready var second_mistake: TextureRect = $Control/SecondMistake

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

@onready var gameplay: AudioStreamPlayer = $Gameplay
@onready var click: AudioStreamPlayer = $Click
@onready var basketball_sheep: AudioStreamPlayer = $BasketballSheep
@onready var soccer_sheep: AudioStreamPlayer = $SoccerSheep

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
	
	first_mistake.visible = false
	second_mistake.visible = false
	
	wool_spot_rule = Sheep.WoolSpot.values().pick_random()
	neck_tag_rule = Sheep.NeckTag.values().pick_random()
	tail_type_rule = Sheep.TailType.values().pick_random()
	
	var sheep = gate_field.spawn_sheep(wool_spot_rule, neck_tag_rule, tail_type_rule)
	imposter_count = sheep.imposter_count
	
	wool_spot_rule_label.text = "Wool Spot = %s" % Sheep.WoolSpot.keys()[wool_spot_rule]
	neck_tag_rule_label.text = "Neck Tag = %s" % Sheep.NeckTag.keys()[neck_tag_rule]
	tail_type_rule_label.text = "Tail Type = %s" % Sheep.TailType.keys()[tail_type_rule]
	
	ResourceLoader.load_threaded_request("uid://b5lo1jvsbpgwb")


func _on_inspection_sheep_tossed(sheep: Sheep) -> void:
	var follow_rule_count = 0
	
	if sheep.wool_spot == wool_spot_rule: follow_rule_count += 1
	if sheep.neck_tag == neck_tag_rule: follow_rule_count += 1
	if sheep.tail_type == tail_type_rule: follow_rule_count += 1
	
	if follow_rule_count >= 2: real_sheep_tossed += 1
	else: imposter_tossed += 1
	
	first_mistake.visible = real_sheep_tossed >= 1
	second_mistake.visible = real_sheep_tossed >= 2
	
	animated_sprite_2d.visible = true
	var toss = TOSS.pick_random()
	animated_sprite_2d.play(toss)
	if toss == "kick": soccer_sheep.play()
	elif toss == "shoot": basketball_sheep.play()
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
	
	if real_sheep_tossed > 2:
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
	click.play()
	get_tree().reload_current_scene()


func _on_restart_wave_button_pressed() -> void:
	click.play()
	get_tree().reload_current_scene()


func _on_gameplay_finished() -> void:
	gameplay.play()
