extends StaticBody2D


# Called when the node enters the scene tree for the first time.

func _process(_float):
	position.x = get_parent().get_node("Player").position.x
