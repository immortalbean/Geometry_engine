@tool
extends StaticBody2D

@onready var collision = $hitbox
@onready var collision2 = $hitbox2
@onready var sprite = $sprite
@export var type = 0
@export var direction: float = 0
func _ready():
	if not Engine.is_editor_hint():
		sprite.frame = type
		sprite.rotation_degrees = direction * 90

func _process(_delta):
	if Engine.is_editor_hint():
		sprite.frame = type
		sprite.rotation_degrees = direction * 90

func player_gravity_u():
	collision.rotation_degrees = 180
	collision2.rotation_degrees = 0
func player_gravity_d():
	collision.rotation_degrees = 0
	collision2.rotation_degrees = 180
func enable_head_collision():
	collision2.set_deferred("disabled",false)
func disable_head_collision():
	collision2.set_deferred("disabled",true)
