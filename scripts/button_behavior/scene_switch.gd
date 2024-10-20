extends Area2D

signal pressed

@export var has_shortcut: bool = false
@export var shortcut = "none"
@export var scene = "res://scene.tscn"
var is_mouse_entered: bool = false

func _process(_delta):
	if Input.is_action_just_released("click") and is_mouse_entered:
		swap()
		emit_signal("pressed")
	if Input.is_action_just_released(shortcut) and has_shortcut:
		swap()
		emit_signal("pressed")

func _mouse_enter():
	is_mouse_entered = true
func _mouse_exit():
	is_mouse_entered = false
func swap():
	get_tree().change_scene_to_file(scene)
