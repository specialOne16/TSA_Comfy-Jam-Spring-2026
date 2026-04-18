extends Control


@onready var menu: AudioStreamPlayer = $Menu
@onready var click: AudioStreamPlayer = $Click


func _on_play_button_pressed() -> void:
	Globals.wave = 1
	click.play()
	get_tree().change_scene_to_file("res://gameplay/gameplay.tscn")


func _on_menu_finished() -> void:
	menu.play()
