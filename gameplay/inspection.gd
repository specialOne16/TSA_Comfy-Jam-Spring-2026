extends Node2D
class_name Inspection

@onready var color_rect: ColorRect = $ColorRect

var inspecting_sheep: Sheep

func inspect(sheep: Sheep):
	if inspecting_sheep: return
	inspecting_sheep = sheep
	
	sheep.z_index = 2
	
	var tween = create_tween()
	tween.set_parallel()
	tween.tween_property(sheep, "position", Vector2(1280, 720), 1)
	tween.tween_property(sheep, "scale", Vector2(10, 10), 1)
	tween.tween_property(color_rect, "color", Color.hex(0xffffff60), 1)
