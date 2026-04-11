extends Node2D
class_name Inspection

enum Pov { SIDE, BACK, FACE }

@onready var color_rect: ColorRect = $Control/ColorRect
@onready var debug_data: Label = $Control/DebugData
@onready var left_button: Button = $Control/LeftButton
@onready var right_button: Button = $Control/RightButton
@onready var h_box_container: HBoxContainer = $Control/HBoxContainer

var inspecting_sheep: Sheep
var pov := Pov.SIDE


func inspect(sheep: Sheep):
	if inspecting_sheep: return
	inspecting_sheep = sheep
	
	sheep.z_index = 2
	
	var tween = create_tween()
	tween.set_parallel()
	tween.tween_property(sheep, "position", Vector2(1280, 720), 1)
	tween.tween_property(sheep, "scale", Vector2.ONE * 8, 1)
	tween.tween_property(color_rect, "color", Color.hex(0x00000060), 1)
	
	setup_button()


func setup_button():
	if inspecting_sheep == null:
		color_rect.color = Color.hex(0x00000000)
		left_button.visible = false
		right_button.visible = false
		h_box_container.visible = false
		debug_data.text = ""
		pov = Pov.SIDE
		return
	
	match pov:
		Pov.SIDE: 
			debug_data.text = "Showing side sheep, wool spot is %s" % Sheep.WoolSpot.keys()[inspecting_sheep.wool_spot]
			
			left_button.visible = true
			right_button.visible = true
			left_button.text = "See back"
			right_button.text = "See face"
		
		Pov.BACK: 
			debug_data.text = "Showing back sheep, tail type is %s" % Sheep.TailType.keys()[inspecting_sheep.tail_type]
			
			left_button.visible = false
			right_button.visible = true
			right_button.text = "See side"
		
		Pov.FACE: 
			debug_data.text = "Showing face sheep, neck tag is %s" % Sheep.NeckTag.keys()[inspecting_sheep.neck_tag]
			left_button.visible = true
			right_button.visible = false
			left_button.text = "See side"
	
	h_box_container.visible = true


func _ready() -> void:
	setup_button()


func _on_left_button_pressed() -> void:
	match pov:
		Pov.SIDE: pov = Pov.BACK
		Pov.BACK: pass
		Pov.FACE: pov = Pov.SIDE
	
	setup_button()


func _on_right_button_pressed() -> void:
	match pov:
		Pov.SIDE: pov = Pov.FACE
		Pov.BACK: pov = Pov.SIDE
		Pov.FACE: pass
	
	setup_button()


func _on_toss_button_pressed() -> void:
	inspecting_sheep.queue_free()
	inspecting_sheep = null
	setup_button()


func _on_keep_button_pressed() -> void:
	var tween = create_tween()
	tween.set_parallel()
	tween.tween_property(inspecting_sheep, "scale", Vector2.ONE, 1)
	tween.tween_property(color_rect, "color", Color.hex(0x00000000), 1)
	
	await tween.finished
	
	inspecting_sheep.z_index = 0
	inspecting_sheep.un_inspect()
	
	inspecting_sheep = null
	setup_button()
