extends Node2D
class_name Inspection

enum Pov { SIDE, BACK, FACE }

const BLACK_SPOTS_TRANSPARENT = preload("uid://ci778t5n7ueqc")
const BROWN_SPOTS_TRANSPARENT = preload("uid://s0ybfrwal7f1")
const NO_SPOTS_TRANSPARENT = preload("uid://7mgqoxiolx1h")
const BLUE_TAG_TRANSPARENT = preload("uid://dlmxoogctgdlp")
const GREEN_TAG_TRANSPARENT = preload("uid://bchwjrp4ewuw7")
const RED_TAG_TRANSPARENT = preload("uid://bcex4dver6tc8")
const LONG_TAIL_TRANSPARENT = preload("uid://r2aovto7i8go")
const NO_TAIL_TRANSPARENT = preload("uid://dl63givpxn3ur")
const SHORT_TAIL_TRANSPARENT = preload("uid://cpvgtxg382kih")

signal sheep_tossed(sheep: Sheep)

@onready var color_rect: ColorRect = $Control/ColorRect
@onready var debug_data: Label = $Control/DebugData
@onready var left_button: TextureButton = $Control/LeftButton
@onready var right_button: TextureButton = $Control/RightButton
@onready var h_box_container: HBoxContainer = $Control/HBoxContainer
@onready var inspection_status: TextureRect = $Control/InspectionStatus

var inspecting_sheep: Sheep
var pov := Pov.SIDE


func inspect(sheep: Sheep):
	if inspecting_sheep: return
	inspecting_sheep = sheep
	
	color_rect.color = Color.hex(0x00000060)
	
	setup_button()


func setup_button():
	if inspecting_sheep == null:
		color_rect.color = Color.hex(0x00000000)
		left_button.visible = false
		right_button.visible = false
		h_box_container.visible = false
		debug_data.text = ""
		pov = Pov.SIDE
		inspection_status.texture = null
		return
	
	match pov:
		Pov.SIDE: 
			debug_data.text = "Showing side sheep, wool spot is %s" % Sheep.WoolSpot.keys()[inspecting_sheep.wool_spot]
			
			match inspecting_sheep.wool_spot:
				Sheep.WoolSpot.BROWN: inspection_status.texture = BROWN_SPOTS_TRANSPARENT
				Sheep.WoolSpot.BLACK: inspection_status.texture = BLACK_SPOTS_TRANSPARENT
				Sheep.WoolSpot.NOTHING: inspection_status.texture = NO_SPOTS_TRANSPARENT
			
			left_button.visible = true
			right_button.visible = true
		
		Pov.BACK: 
			debug_data.text = "Showing back sheep, tail type is %s" % Sheep.TailType.keys()[inspecting_sheep.tail_type]
			
			match inspecting_sheep.tail_type:
				Sheep.TailType.NOTHING: inspection_status.texture = NO_TAIL_TRANSPARENT
				Sheep.TailType.LONG: inspection_status.texture = LONG_TAIL_TRANSPARENT
				Sheep.TailType.SHORT: inspection_status.texture = SHORT_TAIL_TRANSPARENT
			
			left_button.visible = false
			right_button.visible = true
		
		Pov.FACE: 
			debug_data.text = "Showing face sheep, neck tag is %s" % Sheep.NeckTag.keys()[inspecting_sheep.neck_tag]
			
			match inspecting_sheep.neck_tag:
				Sheep.NeckTag.RED: inspection_status.texture = RED_TAG_TRANSPARENT
				Sheep.NeckTag.BLUE: inspection_status.texture = BLUE_TAG_TRANSPARENT
				Sheep.NeckTag.GREEN: inspection_status.texture = GREEN_TAG_TRANSPARENT
			
			left_button.visible = true
			right_button.visible = false
	
	h_box_container.visible = true


func _ready() -> void:
	setup_button()


func _on_left_button_pressed() -> void:
	print("masuk")
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
	sheep_tossed.emit(inspecting_sheep)
	inspecting_sheep.queue_free()
	inspecting_sheep = null
	setup_button()


func _on_keep_button_pressed() -> void:
	color_rect.color = Color.hex(0x00000000)
	inspecting_sheep.un_inspect()
	
	inspecting_sheep = null
	setup_button()


func _on_left_button_mouse_entered() -> void:
	print("halo")
