extends Node2D

@onready var texture = $texture
@export var speed: float = 360

func _process(delta):
	texture.rotation_degrees += speed * delta
