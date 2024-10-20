extends CanvasLayer

@onready var pause_button = $pause
@onready var pause_menu = $pause_menu
var paused: bool = false

signal refresh_pause(paused,hover)
signal send_info(hover)
signal restart_level

func _process(_delta):
	emit_signal("send_info",pause_button.is_mouse_entered)

func _ready():
	
	pause_button.show()
	pause_menu.hide()
func _on_pause_pressed():
	paused = not paused
	emit_signal("refresh_pause",paused)
	if paused:
		pause_menu.show()
		pause_button.hide()
	else:
		pause_menu.hide()
		pause_button.show()


func _on_restart_pressed():
	emit_signal("restart_level")
