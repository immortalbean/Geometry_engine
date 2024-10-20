extends Area2D

signal pressed

@export var has_shortcut: bool = false
@export var shortcut = "none"
var is_mouse_entered: bool = false

func _process(_delta):
	if Input.is_action_just_released("click") and is_mouse_entered:
		emit_signal("pressed")
	if Input.is_action_just_released(shortcut) and has_shortcut:
		emit_signal("pressed")

func _mouse_enter():
	is_mouse_entered = true
func _mouse_exit():
	is_mouse_entered = false
