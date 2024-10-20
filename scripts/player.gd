extends CharacterBody2D

var player_tick: bool = true
var game_paused: bool = false
var music_pause_pos: float = 0
var death_timer_pause: float = 0
var click_buffer: bool = false
var player_speed: float = 10.386
const applied_gravity_cube: float = 8300
const applied_gravity_ship: float = 4000
const applied_gravity_ball: float = 7500
var current_gravity = 1
var direction = 1
const jump_height_cube: float = -1850
const ball_flip_power: float = 400
const ship_power: float = -4000
const jump_orb_height: float = -1850
const jump_pad_height: float = -2500
const boost_orb_height: float = -2500
const boost_pad_height: float = -3250
const drop_orb_power: float = 2500
const hop_orb_height: float = -1400
const hop_pad_height: float = -1800
const gravity_orb_power: float = 1000
const gravity_pad_power: float = 1000
const flip_orb_power: float = -1750
var cancel_jump: bool = false
var current_orb_type = 0
var gamemode = 0
var multiplier: float = 1
var current_orb = "null"
@onready var rot = $rotating
@onready var icon = $rotating/Icon
@onready var death_timer = $death_timer
@onready var camera = $camera
@onready var detection = $rotating/objectdetection
@onready var audio = $audio
@onready var music = $music
@onready var particles = $particles
@onready var pause_layer = get_parent().get_node("pause_layer")

func _ready():
	pause_layer.refresh_pause.connect(_pause)
	pause_layer.send_info.connect(_recieve_info)
	pause_layer.restart_level.connect(die)
	music.play()

func reset_level():
	gamemode = 0
	direction = 1
	icon.visible = true
	icon.frame = 0
	position = Vector2(0, 0)
	set_gravity(1)
	icon.flip_v = false
	velocity.y = 0
	rot.rotation_degrees = 0
	camera.position = Vector2(0, 0)
	music.play(0)
	multiplier = 1
	get_tree().call_group("block", "disable_head_collision")

func _process(delta):
	if not game_paused:
		if player_tick:
			velocity.x = player_speed * 100 * direction
			camera.offset.x += ((125 * direction) - camera.offset.x) / 2
			if gamemode == 0:
				physics_cube(delta)
			if gamemode == 1:
				physics_ship(delta)
			if gamemode == 2:
				physics_ball(delta)
			cancel_jump = false
			test_for_orb()
			move_and_slide()
			if position.y < -20000:
				die()
		if Input.is_action_just_pressed("reset"):
			die()

func _area_on_crash(_area):
	if player_tick:
		die()

func _area_object(area):
	if area.is_in_group("hazard") and player_tick:
		die()
	if area.is_in_group("pad"):
		cancel_jump = true
		click_buffer = false
	if area.is_in_group("jump_pad"):
		velocity.y = jump_pad_height * current_gravity * multiplier
	if area.is_in_group("gravity_pad"):
		set_gravity(current_gravity * -1)
		velocity.y = gravity_pad_power * current_gravity * multiplier
	if area.is_in_group("hop_pad"):
		velocity.y = hop_pad_height * current_gravity * multiplier
	if area.is_in_group("boost_pad"):
		velocity.y = boost_pad_height * current_gravity * multiplier
	if area.is_in_group("jump_orb"):
		current_orb_type = 1
	if area.is_in_group("gravity_orb"):
		current_orb_type = 2
	if area.is_in_group("hop_orb"):
		current_orb_type = 3
	if area.is_in_group("flip_orb"):
		current_orb_type = 4
	if area.is_in_group("boost_orb"):
		current_orb_type = 5
	if area.is_in_group("drop_orb"):
		current_orb_type = 6
	if area.is_in_group("gravity_portal_u"):
		set_gravity(-1)
		velocity.y /= 2
	if area.is_in_group("gravity_portal_d"):
		set_gravity(1)
		velocity.y /= 2
	if area.is_in_group("cube_portal"):
		gamemode = 0
		click_buffer = false
		rotation = 0
		multiplier = 1
		icon.flip_v = false
		icon.frame = 0
		get_tree().call_group("block", "disable_head_collision")
	if area.is_in_group("ship_portal"):
		gamemode = 1
		click_buffer = false
		rot.rotation = 0
		multiplier = 0.6
		icon.frame = 1
		if current_gravity == 1:
			icon.flip_v = false
		else:
			icon.flip_v = true
	if area.is_in_group("ball_portal"):
		gamemode = 2
		click_buffer = false
		rot.rotation = 0
		multiplier = 0.7
		icon.frame = 2
		get_tree().call_group("block", "enable_head_collision")
	if area.is_in_group("orb"):
		current_orb = area

func _area_exit_object(area):
	if area.is_in_group("orb"):
		current_orb_type = 0
		current_orb = null

func _death_timeout():
	player_tick = true
	reset_level()
	
func die():
	death_timer.start()
	player_tick = false
	icon.visible = false
	audio.play()
	music.stop()
	particles.emitting = true
	
func test_for_orb():
	if Input.is_action_just_pressed("jump") or click_buffer:
		if current_orb_type == 1:
			velocity.y = jump_orb_height * current_gravity * multiplier
		if current_orb_type == 2:
			set_gravity(current_gravity * -1)
			velocity.y = gravity_orb_power * current_gravity * multiplier
		if current_orb_type == 3:
			velocity.y = hop_orb_height * current_gravity * multiplier
		if current_orb_type == 4:
			set_gravity(current_gravity * -1)
			velocity.y = flip_orb_power * current_gravity * multiplier
		if current_orb_type == 5:
			velocity.y = boost_orb_height * current_gravity * multiplier
		if current_orb_type == 6:
			velocity.y = drop_orb_power * current_gravity * multiplier
		if current_orb_type:
			click_buffer = false
			current_orb.disable_mode = current_orb.PROCESS_MODE_DISABLED
			if current_orb.is_in_group("reverse"):
				direction *= -1


func _on_music_finished():
	die()


func _pause(paused):
	game_paused = paused
	if paused:
		music_pause_pos = music.get_playback_position()
		music.stop()
		particles.speed_scale = 0
		death_timer_pause = death_timer.time_left
		death_timer.stop()
	else:
		particles.speed_scale = 1
		if death_timer_pause:
			death_timer.start(death_timer_pause)
		else:
			music.play(music_pause_pos)
		death_timer_pause = 0

func _recieve_info(hover):
	if hover:
		cancel_jump = true

func set_gravity(gravity):
	current_gravity = gravity
	if gravity == 1:
		get_tree().call_group("block", "player_gravity_d")
		up_direction = Vector2(0,-1)
		if gamemode == 2:
			icon.flip_v = false
	else:
		get_tree().call_group("block", "player_gravity_u")
		up_direction = Vector2(0,1)
		if gamemode == 2:
			icon.flip_v = true

func physics_cube(delta):
	if Input.is_action_just_pressed("jump"):
		click_buffer = true
	if Input.is_action_just_released("jump"):
			click_buffer = false
	velocity.y += applied_gravity_cube * delta * current_gravity
	if Input.is_action_pressed("jump") and is_on_floor() and not cancel_jump:
		velocity.y = jump_height_cube * current_gravity
		rot.rotation_degrees = snapped(rot.rotation_degrees, 90)
		click_buffer = false
	if is_on_floor():
		rot.rotation_degrees = lerpf(rot.rotation_degrees,snapped(rot.rotation_degrees,90),0.75)
	else:
		rot.rotation_degrees += 360 * delta * current_gravity * direction
func physics_ship(delta):
	if Input.is_action_pressed("jump") and not cancel_jump:
		velocity.y += ship_power * delta * current_gravity
	else:
		velocity.y += applied_gravity_ship * delta * current_gravity
	velocity.y = clamp(velocity.y,-1200,1200)
	rot.rotation += (velocity.angle() - rot.rotation) / 3
func physics_ball(delta):
	if Input.is_action_just_pressed("jump"):
		click_buffer = true
	if Input.is_action_just_released("jump"):
			click_buffer = false
	velocity.y += applied_gravity_ball * delta * current_gravity
	rot.rotation_degrees += 360 * delta * current_gravity * direction
	if Input.is_action_pressed("jump") and is_on_floor() and not cancel_jump:
		set_gravity(0 - current_gravity)
		velocity.y += current_gravity * ball_flip_power
