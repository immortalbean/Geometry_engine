extends CollisionShape2D
var player = get_parent().get_parent().get_node("Player")

# Called when the node enters the scene tree for the first time.
func _ready():
	player.refresh_gravity.connect(_refresh_gravity)

func _refresh_gravity(gravity):
	if gravity == 1:
		rotation_degrees = 0
	else:
		rotation_degrees = 180
