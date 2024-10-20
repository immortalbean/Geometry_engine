extends Node2D

var tick: float = 0
var start_y: float = 0
@export var speed: float = 180
@export var amount: float = 50


func _ready():
	start_y = position.y



func _process(delta):
	position.y = start_y + (sin(tick)*amount)
	tick += speed * delta
