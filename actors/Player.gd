extends CharacterBody2D
class_name Player

signal died
signal fired(bullets)

@export var MAX_SPEED: int = 500
@export var DASH_MULT: int = 2
@export var ACCEL: int = 10000
@export var FRICT: int = 15

@onready var viewport_size: Vector2 = get_viewport_rect().size

var aim: Vector2
var dir: Vector2
var vel: Vector2
var dashing: bool = false
var dash_available: bool = true

var inventory = []
var inventory_idx = 0
var current_gun

func _init():
	if MAX_SPEED > float(ACCEL) / FRICT:
		printerr("MAX_SPEED is greater than terminal velocity (ACCEL/FRICT)")

func _ready():
	if $dash_timer.connect("timeout", _on_dash_timer_timeout):
		printerr("connection failed")
	if $dash_cd.connect("timeout", _on_dash_cd_timeout):
		printerr("connection failed")
	
func _physics_process(delta):
	aim = get_global_mouse_position()
	look_at(aim)
	
	dir = get_input_dir()
	
	if !dashing:
		set_vel(delta)
	
	var collision = move_and_collide(vel * delta)
	if collision && !collision.get_collider().is_queued_for_deletion():
		emit_signal("died")
	position.x = clamp(position.x, 50, viewport_size.x - 50)
	position.y = clamp(position.y, 50, viewport_size.y - 50)
	
func _unhandled_input(event):
	if event.is_action_pressed("ui_dash") && dash_available:
		start_dash()
	if event.is_action_pressed("ui_swap_gun"):
		next_gun()

func get_input_dir() -> Vector2:
	return Vector2(
		int(Input.is_action_pressed("ui_right")) - int(Input.is_action_pressed("ui_left")),
		int(Input.is_action_pressed("ui_down")) - int(Input.is_action_pressed("ui_up"))
	)

func set_vel(delta: float) -> void:
	vel += (dir * ACCEL - vel * FRICT) * delta
	vel = vel.limit_length(MAX_SPEED)

func start_dash() -> void:
	dash_available = false
	dashing = true
	$dash_timer.start()
	$dash_cd.start()
	if dir:
		vel = dir * DASH_MULT * MAX_SPEED
	else:
		vel = global_position.direction_to(aim) * DASH_MULT * MAX_SPEED

func end_dash() -> void:
	vel = Vector2.ZERO

func _on_dash_timer_timeout() -> void:
	dashing = false
	end_dash()

func _on_dash_cd_timeout() -> void:
	dash_available = true

func _on_fire_period_timeout():
	emit_signal("fired", current_gun.spawn_bullets())

func next_gun():
	if len(inventory) == 1: # just one gun in the inventory
		return
	if inventory_idx>= len(inventory) - 1:
		inventory_idx = 0
	else:
		inventory_idx += 1 
	swap_gun_to(inventory_idx)

func swap_gun_to(idx):
	current_gun.queue_free()
	set_gun(idx)

func set_gun(idx):
	current_gun = inventory[idx].instantiate()
	add_child(current_gun)
	var fp = current_gun.get_node("fire_period")
	fp.start()
	fp.connect("timeout", _on_fire_period_timeout)

func add_gun_to_inventory(gun_class):
	if inventory.find(gun_class) != -1:
		# gun already in inventory
		return
	inventory.append(gun_class)

func remove_gun_from_inventory(gun_class):
	var gun_idx = inventory.find(gun_class)
	if gun_idx == -1: # gun is not in inventory
		return
	# if current_gun is an instance of the gun beeing replaced, change player's gun
	if current_gun.get_scene_file_path() == gun_class.get_path(): 
		next_gun()
	inventory.remove_at(gun_idx)
