extends Node

var wave = 0
var sheep: Resource

func _ready() -> void:
	ResourceLoader.load_threaded_request("res://entity/sheep.tscn")

func get_sheep_resource() -> Resource:
	if sheep == null:
		sheep = ResourceLoader.load_threaded_get("res://entity/sheep.tscn")
	
	return sheep
